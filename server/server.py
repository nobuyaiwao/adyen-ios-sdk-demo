import os
import uuid

import requests
from dotenv import load_dotenv
from flask import Flask, jsonify

load_dotenv()

app = Flask(__name__)

ADYEN_API_KEY = os.getenv("ADYEN_API_KEY")
ADYEN_MERCHANT_ACCOUNT = os.getenv("ADYEN_MERCHANT_ACCOUNT")

ADYEN_SESSIONS_URL = "https://checkout-test.adyen.com/v72/sessions"


@app.get("/health")
def health():
    return jsonify({
        "status": "ok",
        "message": "Adyen demo server is running",
    })


@app.post("/sessions")
def create_session():
    if not ADYEN_API_KEY or not ADYEN_MERCHANT_ACCOUNT:
        return jsonify({
            "error": "Missing ADYEN_API_KEY or ADYEN_MERCHANT_ACCOUNT",
        }), 500

    payload = {
        "merchantAccount": ADYEN_MERCHANT_ACCOUNT,
        "reference": f"ios-demo-{uuid.uuid4()}",
        "amount": {
            "currency": "JPY",
            "value": 1000,
        },
        "countryCode": "JP",
        "shopperLocale": "ja-JP",
        "returnUrl": "adyendemo://payment",
    }

    try:
        response = requests.post(
            ADYEN_SESSIONS_URL,
            json=payload,
            headers={
                "X-API-Key": ADYEN_API_KEY,
                "Content-Type": "application/json",
            },
            timeout=30,
        )

        response.raise_for_status()
        return jsonify(response.json())

    except requests.HTTPError:
        return jsonify({
            "error": "Adyen API returned an error",
            "statusCode": response.status_code,
            "adyenResponse": response.json(),
        }), response.status_code

    except requests.RequestException as error:
        return jsonify({
            "error": "Could not connect to Adyen",
            "details": str(error),
        }), 502


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8080,
        debug=True,
    )
