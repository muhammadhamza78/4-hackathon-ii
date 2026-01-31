"""
Application Configuration
Loads environment variables and provides configuration settings.
"""

from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import List
from pydantic import Field


class Settings(BaseSettings):
    # Database Configuration
    DATABASE_URL: str = Field(..., description="Database connection string")

    # JWT Configuration
    JWT_SECRET_KEY: str = Field(..., description="Secret key for signing JWT tokens")
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_HOURS: int = 24

    # Application Configuration
    ENV: str = "development"
    DEBUG: bool = True

    # CORS Configuration
    CORS_ORIGINS: str = Field(..., description="Comma-separated list of allowed CORS origins")

    # Cloud Storage (Optional)
    S3_BUCKET_NAME: str | None = None
    S3_REGION: str | None = "auto"
    S3_ACCESS_KEY_ID: str | None = None
    S3_SECRET_ACCESS_KEY: str | None = None
    S3_ENDPOINT_URL: str | None = None
    S3_PUBLIC_URL: str | None = None

    # AI Provider Selection
    AI_PROVIDER: str = "groq"

    # AI API Keys
    OPENAI_API_KEY: str | None = None
    ANTHROPIC_API_KEY: str | None = None
    GROQ_API_KEY: str | None = None

    # Model selection
    OPENAI_MODEL: str = "gpt-4o"
    ANTHROPIC_MODEL: str = "claude-3-5-sonnet-20241022"
    GROQ_MODEL: str = "llama-3.3-70b-versatile"

    # Chat Configuration
    CHAT_RATE_LIMIT: int = 10
    CHAT_TIMEOUT_SECONDS: int = 30
    CHAT_MAX_MESSAGE_LENGTH: int = 2000
    CHAT_CONTEXT_MESSAGES: int = 20

    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"

    def cors_origins_list(self) -> List[str]:
        return [o.strip() for o in self.CORS_ORIGINS.split(",") if o.strip()]


@lru_cache()
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
