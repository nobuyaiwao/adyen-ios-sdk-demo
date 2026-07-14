import uuid

import requests
from flask import Flask, jsonify

from config import config


app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(
        {
            "status": "ok",
            "message": "Adyen demo server is running",
            "environment": config.environment,
        }
    )


@app.post("/sessions")
def create_session():

    sessions_url = f"{config.checkout_base_url}/sessions"

    payload = {
        "merchantAccount": config.merchant_account,
        "reference": f"ios-demo-{uuid.uuid4()}",
        "amount": {
            "currency": "JPY",
            "value": 1000,
        },
        "countryCode": "JP",
        "shopperLocale": "ja-JP",
        "returnUrl": config.return_url,
    }
    print(f"POST {sessions_url}")
    print(payload)

    try:
        response = requests.post(
            sessions_url,
            json=payload,
            headers={
                "X-API-Key": config.api_key,
                "Content-Type": "application/json",
            },
            timeout=30,
        )
        print(f"Status: {response.status_code}")

    except requests.RequestException as error:
        app.logger.exception("Could not connect to Adyen")

        return jsonify(
            {
                "error": "Could not connect to Adyen",
                "details": str(error),
            }
        ), 502

    try:
        response_body = response.json()
    except ValueError:
        response_body = {
            "rawResponse": response.text,
        }

    if not response.ok:
        app.logger.error(
            "Adyen API error: status=%s response=%s",
            response.status_code,
            response_body,
        )

        return jsonify(
            {
                "error": "Adyen API returned an error",
                "statusCode": response.status_code,
                "adyenResponse": response_body,
            }
        ), response.status_code

    return jsonify(response_body)


def print_startup_configuration() -> None:
    separator = "=" * 60

    print(separator)
    print("Adyen iOS SDK demo backend")
    print(f"Environment: {config.environment.upper()}")
    print(f"Merchant account: {config.merchant_account}")
    print(f"Checkout URL: {config.checkout_base_url}")
    print(separator)

    if config.environment == "live":
        print("WARNING: THIS SERVER IS USING THE ADYEN LIVE ENVIRONMENT")
        print(separator)


if __name__ == "__main__":
    print_startup_configuration()

    app.run(
        host="127.0.0.1",
        port=8080,
        debug=True,
    )
