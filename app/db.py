"""SQLite 数据层：帖子调度 + 全局设置（含 token 持久化）。

零依赖，仅用标准库 sqlite3。
"""
from __future__ import annotations

import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from app.config import cfg

_SCHEMA = """
CREATE TABLE IF NOT EXISTS posts (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    platform      TEXT NOT NULL DEFAULT 'both',       -- facebook | instagram | both
    title         TEXT,
    caption_bm    TEXT,
    caption_en    TEXT,
    media_path    TEXT,
    media_type    TEXT DEFAULT 'none',                 -- image | video | none
    theme         TEXT,
    scheduled_at  TEXT,                                -- ISO 8601
    status        TEXT NOT NULL DEFAULT 'draft',       -- draft|scheduled|published|failed|pending_token
    external_id   TEXT,                                -- Meta 返回的发帖 ID
    published_at  TEXT,
    error         TEXT,
    created_at    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings (
    key   TEXT PRIMARY KEY,
    value TEXT
);
"""


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


@contextmanager
def _conn():
    Path(cfg.DB_PATH).parent.mkdir(parents=True, exist_ok=True)
    c = sqlite3.connect(cfg.DB_PATH)
    c.row_factory = sqlite3.Row
    try:
        yield c
        c.commit()
    finally:
        c.close()


def init_db() -> None:
    with _conn() as c:
        c.executescript(_SCHEMA)
    # 若 .env 里有 token，同步进 settings 表（便于控制中心修改）
    if cfg.ACCESS_TOKEN:
        set_setting("access_token", cfg.ACCESS_TOKEN)


# ─── settings ───
def get_setting(key: str, default: str = "") -> str:
    with _conn() as c:
        row = c.execute("SELECT value FROM settings WHERE key=?", (key,)).fetchone()
    return row["value"] if row else default


def set_setting(key: str, value: str) -> None:
    with _conn() as c:
        c.execute(
            "INSERT INTO settings(key, value) VALUES(?, ?) "
            "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
            (key, value),
        )


# ─── posts ───
def create_post(**fields) -> int:
    fields.setdefault("created_at", _now())
    fields.setdefault("status", "draft")
    cols = list(fields.keys())
    placeholders = ", ".join("?" for _ in cols)
    with _conn() as c:
        cur = c.execute(
            f"INSERT INTO posts({', '.join(cols)}) VALUES({placeholders})",
            [fields[k] for k in cols],
        )
        return cur.lastrowid


def update_post(pid: int, **fields) -> None:
    if not fields:
        return
    sets = ", ".join(f"{k}=?" for k in fields)
    with _conn() as c:
        c.execute(f"UPDATE posts SET {sets} WHERE id=?", [*fields.values(), pid])


def get_post(pid: int) -> Optional[sqlite3.Row]:
    with _conn() as c:
        return c.execute("SELECT * FROM posts WHERE id=?", (pid,)).fetchone()


def list_posts(limit: int = 50, status: Optional[str] = None) -> list[sqlite3.Row]:
    with _conn() as c:
        if status:
            return c.execute(
                "SELECT * FROM posts WHERE status=? ORDER BY id DESC LIMIT ?",
                (status, limit),
            ).fetchall()
        return c.execute(
            "SELECT * FROM posts ORDER BY id DESC LIMIT ?", (limit,)
        ).fetchall()


def due_posts(now_iso: str) -> list[sqlite3.Row]:
    """返回已到调度时间且未发布的帖子。"""
    with _conn() as c:
        return c.execute(
            "SELECT * FROM posts WHERE scheduled_at IS NOT NULL "
            "AND scheduled_at <= ? AND status IN ('scheduled','pending_token') "
            "ORDER BY scheduled_at ASC",
            (now_iso,),
        ).fetchall()
