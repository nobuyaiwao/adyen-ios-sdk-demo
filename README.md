# Adyen iOS Native SDK Demo

A simple demo project for experimenting with the Adyen iOS Native SDK.
This repository is intentionally built from scratch instead of using the official Adyen demo application.

The goal of this repository is to provide a lightweight environment for testing Adyen payment methods and SDK features without relying on the official demo app.

> **Status:** Work in progress 🚧

## Features

- ✅ SwiftUI application
- ✅ Flask backend
- ✅ Sessions Flow
- ✅ Adyen Drop-in
- ⏳ Card payments
- ⏳ Apple Pay
- ⏳ PayPay
- ⏳ Redirect payment methods
- ⏳ 3D Secure 2
- ⏳ Partial payments

---

## Requirements

- Xcode 26+
- iOS Simulator
- Python 3.11+
- Adyen Test Account

---

## Project Structure

```
adyen-ios-native-sdk-demo
├── AdyenDemo
│   ├── AdyenDemo.xcodeproj
│   ├── ContentView.swift
│   ├── PaymentManager.swift
│   ├── Secrets.xcconfig
│   └── ...
└── server
    ├── server.py
    ├── requirements.txt
    └── .env
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

Create `.env`.

```env
ADYEN_API_KEY=YOUR_API_KEY
ADYEN_MERCHANT_ACCOUNT=YOUR_MERCHANT_ACCOUNT
```

Run the server.

```bash
python server.py
```

The server will start on

```
http://127.0.0.1:8080
```

---

## iOS Configuration

Copy

```
Secrets.xcconfig.example
```

to

```
Secrets.xcconfig
```

and configure

```text
ADYEN_CLIENT_KEY=test_xxxxxxxxxxxxxxxxx
```

---

## Running

1. Start the Flask server.

2. Open

```
AdyenDemo.xcodeproj
```

3. Run the app.

4. Tap

```
Start payment
```

---

## Notes

This project intentionally keeps the backend extremely small so that the iOS SDK behavior can be tested independently.

The Adyen API Key is stored only on the backend.

The Client Key is loaded from `Secrets.xcconfig`, which is excluded from Git.

---

## Roadmap

- [x] Sessions API
- [x] Drop-in
- [ ] Card Component
- [ ] Apple Pay
- [ ] PayPay
- [ ] Redirect flow
- [ ] 3DS2
- [ ] Return URL handling
- [ ] Stored Payment Methods
- [ ] Partial Payments
- [ ] Logging improvements

---

## License

MIT
