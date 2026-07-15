import Foundation
import Adyen

enum AppEnvironment: String {
    case test
    case live
}

enum AppConfiguration {

    static let environment: AppEnvironment = {
        let value = requiredString(
            forKey: "ADYEN_ENVIRONMENT"
        ).lowercased()

        guard let environment = AppEnvironment(rawValue: value) else {
            fatalError(
                """
                Invalid ADYEN_ENVIRONMENT: \(value)
                Expected "test" or "live".
                """
            )
        }

        return environment
    }()

    static let clientKey: String = {
        let value = requiredString(forKey: "ADYEN_CLIENT_KEY")

        switch environment {
        case .test:
            guard value.hasPrefix("test_") else {
                fatalError(
                    "Test environment requires a test_ Client Key."
                )
            }

        case .live:
            guard value.hasPrefix("live_") else {
                fatalError(
                    "Live environment requires a live_ Client Key."
                )
            }
        }

        return value
    }()

    static let backendBaseURL: URL = {
        let value = requiredString(forKey: "BACKEND_BASE_URL")

        guard let url = URL(string: value) else {
            fatalError("Invalid BACKEND_BASE_URL: \(value)")
        }

        return url
    }()

    static var sessionsURL: URL {
        backendBaseURL.appendingPathComponent("sessions")
    }

    static var adyenSDKEnvironment: Environment {
        switch environment {
        case .test:
            return Environment.test

        case .live:
            return Environment.liveEurope
        }
    }

    private static func requiredString(
        forKey key: String
    ) -> String {
        guard
            let value = Bundle.main.object(
                forInfoDictionaryKey: key
            ) as? String,
            !value.isEmpty,
            !value.contains("$(")
        else {
            fatalError(
                """
                Missing or unresolved configuration value: \(key)
                Check Info.plist and the active xcconfig.
                """
            )
        }

        return value
    }
}
