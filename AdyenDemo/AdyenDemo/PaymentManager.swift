import Foundation
import Combine
import UIKit

import Adyen
import AdyenActions
import AdyenCard
import AdyenDropIn
import AdyenSession

@MainActor
final class PaymentManager: NSObject, ObservableObject {

    // MARK: - UI State

    @Published var statusMessage = "Ready"
    @Published var isLoading = false

    // MARK: - Adyen Objects

    // Keep strong references while the payment flow is running.
    private var adyenSession: AdyenSession?
    private var dropInComponent: DropInComponent?

    // MARK: - Configuration



    // MARK: - Public API

    func startPayment() {
        guard !isLoading else {
            return
        }

        isLoading = true
        statusMessage = "Creating Adyen session..."

        print(
            "Starting payment:",
            AppConfiguration.environment.rawValue.uppercased()
        )
        print("Backend:", AppConfiguration.backendBaseURL.absoluteString)

        Task {
            do {
                let response = try await fetchSession()

                print("Session ID:", response.id)
                print("Session data length:", response.sessionData.count)

                try initializeAdyenSession(using: response)
            } catch {
                isLoading = false
                statusMessage = "Error: \(error.localizedDescription)"
                print("Payment error:", error)
            }
        }
    }

    // MARK: - Backend Communication

    private func fetchSession() async throws -> SessionResponse {
        let url = AppConfiguration.sessionsURL

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let responseBody =
                String(data: data, encoding: .utf8)
                ?? "Unknown server error"

            throw PaymentManagerError.serverError(
                statusCode: httpResponse.statusCode,
                body: responseBody
            )
        }

        do {
            return try JSONDecoder().decode(
                SessionResponse.self,
                from: data
            )
        } catch {
            let responseBody =
                String(data: data, encoding: .utf8)
                ?? "Unable to read response body"

            print("Session decoding failed. Response:", responseBody)
            throw error
        }
    }

    // MARK: - Adyen Session

    private func initializeAdyenSession(
        using response: SessionResponse
    ) throws {
        let apiContext = try APIContext(
            environment: AppConfiguration.adyenSDKEnvironment,
            clientKey: AppConfiguration.clientKey
        )

        let payment = Payment(
            amount: Amount(
                value: 1000,
                currencyCode: "JPY"
            ),
            countryCode: "JP"
        )

        let context = AdyenContext(
            apiContext: apiContext,
            payment: payment
        )

        let configuration = AdyenSession.Configuration(
            sessionIdentifier: response.id,
            initialSessionData: response.sessionData,
            context: context
        )

        statusMessage = "Initializing Adyen session..."

        AdyenSession.initialize(
            with: configuration,
            delegate: self,
            presentationDelegate: self
        ) { [weak self] result in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.isLoading = false

                switch result {
                case let .success(session):
                    self.adyenSession = session
                    self.statusMessage = "Session initialized"

                    self.presentDropIn(
                        session: session,
                        context: context
                    )

                case let .failure(error):
                    self.statusMessage =
                        "Session error: \(error.localizedDescription)"

                    print(
                        "AdyenSession initialization error:",
                        error
                    )
                }
            }
        }
    }

    // MARK: - Drop-in

    private func presentDropIn(
        session: AdyenSession,
        context: AdyenContext
    ) {
        let configuration = DropInComponent.Configuration()

        let dropIn = DropInComponent(
            paymentMethods: session.sessionContext.paymentMethods,
            context: context,
            configuration: configuration
        )

        // AdyenSession handles submissions and additional actions.
        dropIn.delegate = session
        dropIn.storedPaymentMethodsDelegate = session
        dropIn.partialPaymentDelegate = session

        // Retain the Drop-in for the duration of the flow.
        dropInComponent = dropIn

        guard let presenter = topViewController() else {
            statusMessage = "Unable to find a view controller"
            return
        }

        statusMessage = "Drop-in opened"

        presenter.present(
            dropIn.viewController,
            animated: true
        )
    }

    // MARK: - Presentation Helpers

    private func topViewController() -> UIViewController? {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: {
                    $0.activationState == .foregroundActive
                }),
            let rootViewController = windowScene.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        else {
            return nil
        }

        return topViewController(from: rootViewController)
    }

    private func topViewController(
        from viewController: UIViewController
    ) -> UIViewController {
        if let presentedViewController =
            viewController.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        if let navigationController =
            viewController as? UINavigationController,
           let visibleViewController =
            navigationController.visibleViewController {
            return topViewController(from: visibleViewController)
        }

        if let tabBarController =
            viewController as? UITabBarController,
           let selectedViewController =
            tabBarController.selectedViewController {
            return topViewController(from: selectedViewController)
        }

        return viewController
    }

    private func dismissPresentedComponent(
        completion: (() -> Void)? = nil
    ) {
        guard let presenter = topViewController() else {
            completion?()
            return
        }

        presenter.dismiss(
            animated: true,
            completion: completion
        )
    }
}

// MARK: - Backend Models

struct SessionResponse: Decodable {
    let id: String
    let sessionData: String
}

// MARK: - Errors

enum PaymentManagerError: LocalizedError {
    case serverError(statusCode: Int, body: String)

    var errorDescription: String? {
        switch self {
        case let .serverError(statusCode, body):
            return "Server returned \(statusCode): \(body)"
        }
    }
}

// MARK: - AdyenSessionDelegate

extension PaymentManager: AdyenSessionDelegate {

    func didComplete(
        with result: AdyenSessionResult,
        component: Component,
        session: AdyenSession
    ) {
        component.finalizeIfNeeded(with: true) { [weak self] in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.dismissPresentedComponent {
                    self.statusMessage =
                        "Payment result: \(result.resultCode.rawValue)"
                }

                self.dropInComponent = nil
                self.adyenSession = nil
            }
        }
    }

    func didFail(
        with error: Error,
        from component: Component,
        session: AdyenSession
    ) {
        component.finalizeIfNeeded(with: false) { [weak self] in
            Task { @MainActor in
                guard let self else {
                    return
                }

                self.dismissPresentedComponent {
                    self.statusMessage =
                        "Payment failed: \(error.localizedDescription)"
                }

                self.dropInComponent = nil
                self.adyenSession = nil
            }
        }
    }

    func didOpenExternalApplication(
        component: ActionComponent,
        session: AdyenSession
    ) {
        statusMessage = "External application opened"
    }
}

// MARK: - PresentationDelegate

extension PaymentManager: PresentationDelegate {

    func present(component: PresentableComponent) {
        // No implementation is required for the Sessions flow.
        // AdyenSession handles Action Component presentation.
    }
}
