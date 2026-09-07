"""Warisan Aleen AI Agent — FastAPI 后端入口。

路由概览：
  GET  /                   健康检查 + 概览
  GET  /status             配置状态（token/dry_run/模型/帖子统计）
  POST /generate           用 Ollama 生成一篇帖子（存为 draft）
  GET  /posts              列出帖子
  GET  /posts/{id}         帖子详情
  POST /posts/{id}/schedule  设置调度时间
  POST /posts/{id}/publish   发布（受 token + DRY_RUN 控制）
  POST /publish/due        发布所有到点的帖子（n8n cron 调用）
  GET  /settings           公开设置（token 脱敏）
  POST /settings/token     设置访问令牌（持久化）
  POST /settings/dryrun    切换演练模式
"""
from __future__ import annotations

from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from app import db, ollama_client, publisher, templates
from app.config import cfg

app = FastAPI(title="Warisan Aleen AI Agent", version="0.1.0")


# ─── 请求模型 ───
class GenerateReq(BaseModel):
    topic: str = ""
    platform: str = "both"  # facebook | instagram | both


class ScheduleReq(BaseModel):
    scheduled_at: str  # ISO 8601


class TokenReq(BaseModel):
    token: str


class DryRunReq(BaseModel):
    dry_run: bool


# ─── 路由 ───
@app.get("/")
def root():
    return {
        "service": "Warisan Aleen AI Agent",
        "status": "ok",
        "has_token": cfg.has_token,
        "dry_run": cfg.DRY_RUN,
        "model": cfg.OLLAMA_MODEL,
    }


@app.get("/status")
def status():
    posts = db.list_posts(limit=1000)
    by_status = {}
    for p in posts:
        by_status[p["status"]] = by_status.get(p["status"], 0) + 1
    return {
        "ollama_base": cfg.OLLAMA_BASE_URL,
        "ollama_model": cfg.OLLAMA_MODEL,
        "ollama_models": ollama_client.list_local_models(),
        "has_token": cfg.has_token,
        "dry_run": cfg.DRY_RUN,
        "posts_per_day": cfg.POSTS_PER_DAY,
        "fb_page_id": cfg.FB_PAGE_ID,
        "ig_account_id": cfg.IG_ACCOUNT_ID,
        "post_count": len(posts),
        "by_status": by_status,
    }


@app.post("/generate")
def generate(req: GenerateReq):
    source = "ollama"
    if cfg.USE_OLLAMA:
        try:
            data = ollama_client.generate_post(req.topic)
        except ollama_client.OllamaError as e:
            # Ollama 不可用（资源/模型未加载）→ 品牌模板兜底，保证 Agent 仍产出文案
            data = templates.template_post(req.topic)
            source = "template"
    else:
        data = templates.template_post(req.topic)
        source = "template"
    pid = db.create_post(
        platform=req.platform,
        title=data.get("title", ""),
        caption_bm=data.get("caption_bm", ""),
        caption_en=data.get("caption_en", ""),
        theme=data.get("theme", ""),
        status="draft",
    )
    return {"id": pid, "source": source, **data}


@app.get("/posts")
def posts(limit: int = 50, status: str | None = None):
    return [dict(p) for p in db.list_posts(limit=limit, status=status)]


@app.get("/posts/{pid}")
def post_detail(pid: int):
    p = db.get_post(pid)
    if not p:
        raise HTTPException(404, "post not found")
    return dict(p)


@app.post("/posts/{pid}/schedule")
def schedule(pid: int, req: ScheduleReq):
    p = db.get_post(pid)
    if not p:
        raise HTTPException(404, "post not found")
    db.update_post(pid, scheduled_at=req.scheduled_at, status="scheduled")
    return {"id": pid, "scheduled_at": req.scheduled_at, "status": "scheduled"}


@app.post("/posts/{pid}/publish")
def publish(pid: int):
    p = db.get_post(pid)
    if not p:
        raise HTTPException(404, "post not found")
    if not (p["caption_bm"] or p["caption_en"]):
        raise HTTPException(400, "帖子无文案，无法发布")
    result = publisher.publish_post(dict(p))
    return result


@app.post("/publish/due")
def publish_due():
    """由 n8n cron 调用：发布所有已到调度时间且未发布的帖子。"""
    now = datetime.now(timezone.utc).isoformat()
    due = db.due_posts(now)
    out = []
    for p in due:
        out.append({"id": p["id"], **publisher.publish_post(dict(p))})
    return {"checked_at": now, "due": len(due), "results": out}


@app.get("/settings")
def get_settings():
    tok = db.get_setting("access_token", cfg.ACCESS_TOKEN)
    return {
        "has_token": bool(tok),
        "token_masked": (tok[:6] + "…" + tok[-4:]) if len(tok) > 12 else ("set" if tok else ""),
        "dry_run": cfg.DRY_RUN,
        "model": cfg.OLLAMA_MODEL,
        "posts_per_day": cfg.POSTS_PER_DAY,
        "fb_page_id": cfg.FB_PAGE_ID,
        "ig_account_id": cfg.IG_ACCOUNT_ID,
    }


@app.post("/settings/token")
def set_token(req: TokenReq):
    db.set_setting("access_token", req.token)
    cfg.ACCESS_TOKEN = req.token  # 运行期生效
    return {"ok": True, "has_token": bool(req.token)}


@app.post("/settings/dryrun")
def set_dryrun(req: DryRunReq):
    db.set_setting("dry_run", "true" if req.dry_run else "false")
    cfg.DRY_RUN = req.dry_run
    return {"ok": True, "dry_run": req.dry_run}
