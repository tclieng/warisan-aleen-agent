"""Warisan Aleen AI Agent — 配置层。

所有配置从环境变量 / .env 读取，便于零月费自托管部署。
"""
from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv

# 项目根目录（warisan-agent/）
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")


def _env(key: str, default: str = "") -> str:
    return os.getenv(key, default).strip()


class Config:
    # Ollama
    OLLAMA_BASE_URL: str = _env("OLLAMA_BASE_URL", "http://localhost:11434")
    OLLAMA_MODEL: str = _env("OLLAMA_MODEL", "llama3.2:1b")

    # Meta 资产
    FB_PAGE_ID: str = _env("FB_PAGE_ID", "1369264899593189")
    IG_ACCOUNT_ID: str = _env("IG_ACCOUNT_ID", "17841425967343775")
    INSTAGRAM_USERNAME: str = _env("INSTAGRAM_USERNAME", "warisanaleen")
    BUSINESS_ID: str = _env("BUSINESS_ID", "1070676568896535")

    # 发布
    ACCESS_TOKEN: str = _env("ACCESS_TOKEN", "")
    DRY_RUN: bool = _env("DRY_RUN", "true").lower() in ("1", "true", "yes", "on")
    POSTS_PER_DAY: int = int(_env("POSTS_PER_DAY", "2") or "2")
    # 是否启用本地 Ollama 生成。宿主内存不足（如 <4GB）时设 false，直走品牌模板兜底。
    USE_OLLAMA: bool = _env("USE_OLLAMA", "true").lower() in ("1", "true", "yes", "on")

    # DB / 服务
    DB_PATH: str = str(BASE_DIR / _env("DB_PATH", "warisan.db"))
    HOST: str = _env("HOST", "0.0.0.0")
    PORT: int = int(_env("PORT", "8000") or "8000")

    # 媒体目录
    MEDIA_DIR: Path = BASE_DIR / "media"
    MEDIA_DIR.mkdir(parents=True, exist_ok=True)

    @property
    def has_token(self) -> bool:
        return bool(self.ACCESS_TOKEN)


cfg = Config()
