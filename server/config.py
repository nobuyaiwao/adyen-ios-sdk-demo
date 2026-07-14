from dataclasses import dataclass
import os

from dotenv import load_dotenv


config_file = os.getenv("ADYEN_CONFIG", ".env.test")
load_dotenv(config_file)


@dataclass(frozen=True)
class Config:
    environment: str
    api_key: str
    merchant_account: str
    api_version: str
    live_endpoint_prefix: str
    return_url: str

    @property
    def checkout_base_url(self) -> str:
        if self.environment == "test":
            return (
                f"https://checkout-test.adyen.com/"
                f"{self.api_version}"
            )

        if self.environment == "live":
            if not self.live_endpoint_prefix:
                raise ValueError(
                    "ADYEN_LIVE_ENDPOINT_PREFIX is required "
                    "for the live environment."
                )

            return (
                f"https://{self.live_endpoint_prefix}"
                f"-checkout-live.adyenpayments.com/"
                f"checkout/{self.api_version}"
            )

        raise ValueError(
            f"Unsupported ADYEN_ENVIRONMENT: {self.environment}"
        )


config = Config(
    environment=os.getenv(
        "ADYEN_ENVIRONMENT",
        "test",
    ).lower(),
    api_key=os.environ["ADYEN_API_KEY"],
    merchant_account=os.environ["ADYEN_MERCHANT_ACCOUNT"],
    api_version=os.getenv(
        "ADYEN_API_VERSION",
        "v72",
    ),
    live_endpoint_prefix=os.getenv(
        "ADYEN_LIVE_ENDPOINT_PREFIX",
        "",
    ),
    return_url=os.getenv(
        "ADYEN_RETURN_URL",
        "adyendemo://payment",
    ),
)
