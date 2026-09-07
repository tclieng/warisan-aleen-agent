"""Meta Graph API 发布模块（token 就绪后启用）。

设计原则：
- 无 token 或 DRY_RUN=true 时 → 不真正发帖，仅返回"将要做"的预览（dry_run）。
- 有 token 且 DRY_RUN=false → 调用 Graph API 发到 FB Page / Instagram。
- 所有外部调用失败都安全捕获，写入 post 的 error 字段，不抛崩。

FB Page 发帖：  POST /{page_id}/feed
IG 发帖：       POST /{ig_user_id}/media  (创建) → /media_publish (发布)
                IG 需要图片为可公开访问的 URL（或日后改用二进制容器上传）。
"""
from __future__ import annotations

import httpx
from datetime import datetime, timezone

from app.config import cfg
from app.db import get_setting, update_post

GRAPH = "https://graph.facebook.com/v20.0"


def _token() -> str:
    return cfg.ACCESS_TOKEN or get_setting("access_token", "")


def _combine_caption(post: dict) -> str:
    bm = (post.get("caption_bm") or "").strip()
    en = (post.get("caption_en") or "").strip()
    parts = [p for p in (bm, en) if p]
    return "\n\n".join(parts)


def _publish_facebook(caption: str, token: str) -> str:
    r = httpx.post(
        f"{GRAPH}/{cfg.FB_PAGE_ID}/feed",
        data={"message": caption, "access_token": token},
        timeout=30.0,
    )
    r.raise_for_status()
    return r.json().get("id", "")


def _publish_instagram(caption: str, media_url: str | None, token: str) -> str:
    # 1) 创建媒体容器
    create = {"caption": caption, "access_token": token}
    if media_url:
        create["image_url"] = media_url
    else:
        # 纯文字 IG 帖需附带图片，否则用占位（实际部署应有图）
        create["image_url"] = ""  # 调用方需保证有图
    r = httpx.post(
        f"{GRAPH}/{cfg.IG_ACCOUNT_ID}/media", data=create, timeout=30.0
    )
    r.raise_for_status()
    creation_id = r.json().get("id")
    # 2) 发布
    pub = httpx.post(
        f"{GRAPH}/{cfg.IG_ACCOUNT_ID}/media_publish",
        data={"creation_id": creation_id, "access_token": token},
        timeout=30.0,
    )
    pub.raise_for_status()
    return pub.json().get("id", "")


def publish_post(post: dict) -> dict:
    """发布一条已生成帖子。返回 {dry_run, status, external_id, error}。"""
    token = _token()
    caption = _combine_caption(post)
    platform = (post.get("platform") or "both").lower()
    media_url = post.get("media_path") or None

    now = datetime.now(timezone.utc).isoformat()

    # 无 token：只能等验证后补
    if not token:
        update_post(post["id"], status="pending_token",
                    error="ACCESS_TOKEN 未配置（Business Verification 通过后填入）")
        return {"dry_run": True, "status": "pending_token",
                "external_id": "", "error": "no_token",
                "preview": {"platform": platform, "caption": caption[:120] + "…" if len(caption) > 120 else caption}}

    # 有 token 但处于演练模式
    if cfg.DRY_RUN:
        update_post(post["id"], status="scheduled",
                    error="DRY_RUN=true，未真正发帖")
        return {"dry_run": True, "status": "scheduled", "external_id": "",
                "error": "",
                "preview": {"platform": platform, "caption": caption[:120] + "…" if len(caption) > 120 else caption}}

    # 真正发布
    results = {}
    try:
        if platform in ("facebook", "both"):
            results["facebook"] = _publish_facebook(caption, token)
        if platform in ("instagram", "both"):
            results["instagram"] = _publish_instagram(caption, media_url, token)
        ext = ",".join(f"{k}:{v}" for k, v in results.items())
        update_post(post["id"], status="published", external_id=ext,
                    published_at=now, error="")
        return {"dry_run": False, "status": "published", "external_id": ext, "error": ""}
    except (httpx.HTTPError, KeyError) as e:
        err = str(e)
        update_post(post["id"], status="failed", error=err[:500])
        return {"dry_run": False, "status": "failed", "external_id": "", "error": err[:500]}
