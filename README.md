# Adyen iOS Native SDK Demo

A lightweight demo application for experimenting with the Adyen iOS Native SDK.

Unlike the official Adyen demo application, this project is intentionally built from scratch to provide a minimal, easy-to-understand example that focuses on the merchant integration.

The project includes both a SwiftUI application and a minimal Flask backend implementing the Sessions API.

> **Status:** Work in progress 🚧

---

## Features

- ✅ SwiftUI
- ✅ Flask backend
- ✅ Sessions Flow
- ✅ Adyen Drop-in
- ✅ Test / Live environment switching
- ✅ Build Configurations & Schemes
- ✅ Card payments
- ✅ PayPay (Redirect)
- ⏳ Apple Pay
- ⏳ 3D Secure 2
- ⏳ Stored Payment Methods
- ⏳ Partial Payments

---

## Requirements

- Xcode 26+
- Python 3.11+
- iOS 17+
- Adyen Test account

---

## Project Structure

```
adyen-ios-native-sdk-demo
├── AdyenDemo
│   ├── AdyenDemo.xcodeproj
│   ├── AdyenDemo
│   │   ├── ContentView.swift
│   │   ├── PaymentManager.swift
│   │   ├── AppConfiguration.swift
│   │   ├── Config
│   │   │   ├── Base.xcconfig
│   │   │   ├── Test.xcconfig
│   │   │   ├── Live.xcconfig
│   │   │   ├── Secrets.test.xcconfig.example
│   │   │   └── Secrets.live.xcconfig.example
│   │   └── ...
│   └── ...
└── server
    ├── config.py
    ├── server.py
    ├── requirements.txt
    ├── .env.test.example
    └── .env.live.example
```

---

## Backend

Create a virtual environment.

```bash
cd server

python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
```

Create configuration files.

```
.env.test
.env.live
```

Example:

```env
ADYEN_API_KEY=YOUR_API_KEY
ADYEN_MERCHANT_ACCOUNT=YOUR_MERCHANT_ACCOUNT
```

Start the Test server.

```bash
ADYEN_CONFIG=.env.test python server.py
```

Start the Live server.

```bash
ADYEN_CONFIG=.env.live python server.py
```

The backend listens on

```
http://127.0.0.1:8080
```

---

## iOS Configuration

Copy

```
Secrets.test.xcconfig.example
```

to

```
Secrets.test.xcconfig
```

and

```
Secrets.live.xcconfig.example
```

to

```
Secrets.live.xcconfig
```

Configure each file with the appropriate Client Key.

Example:

```text
ADYEN_CLIENT_KEY=test_xxxxxxxxxxxxxxxxx
```

or

```text
ADYEN_CLIENT_KEY=live_xxxxxxxxxxxxxxxxx
```

---

## Build Configurations

The project contains dedicated Build Configurations and Schemes for Test and Live environments.

### Schemes

- AdyenDemo-Test
- AdyenDemo-Live

Each scheme automatically selects the corresponding Client Key and backend configuration.

---

## Running

1. Start the backend.

2. Open

```
AdyenDemo.xcodeproj
```

3. Select either

```
AdyenDemo-Test
```

or

```
AdyenDemo-Live
```

4. Press **Run**.

5. Tap

```
Start payment
```

---

## Notes

- The backend only stores the Adyen API Key.
- Client Keys are stored in local `.xcconfig` files and are excluded from Git.
- Test and Live environments are isolated using dedicated Build Configurations and Schemes.
- This project intentionally keeps the backend minimal to focus on the iOS SDK integration.

---

## Roadmap

- [x] Sessions Flow
- [x] Drop-in
- [x] Test / Live switching
- [x] PayPay Redirect
- [ ] Return URL handling
- [ ] Apple Pay
- [ ] Card Component
- [ ] 3D Secure 2
- [ ] Stored Payment Methods
- [ ] Partial Payments
- [ ] Logging improvements

---

## License

MIT