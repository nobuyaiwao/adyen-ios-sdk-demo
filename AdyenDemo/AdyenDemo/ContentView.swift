import SwiftUI

struct ContentView: View {
    @StateObject private var paymentManager = PaymentManager()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "creditcard")
                .font(.system(size: 64))

            Text("Adyen iOS Demo")
                .font(.title)
                .fontWeight(.bold)

            Text(paymentManager.statusMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if paymentManager.isLoading {
                ProgressView()
            }

            Button("Start payment") {
                paymentManager.startPayment()
            }
            .buttonStyle(.borderedProminent)
            .disabled(paymentManager.isLoading)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
