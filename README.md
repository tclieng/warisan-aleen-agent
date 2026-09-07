# Warisan Aleen AI Marketing Agent

零月成本、自托管的 AI 社媒营销 Agent：为马来甘榜传统美食品牌 **Warisan Aleen** 自动生成
Bahasa Malaysia + English 双语文案，并发布到 Facebook Page 与 Instagram。

> ⚠️ **当前状态**：Access Token 尚未获取（Meta Business Verification 卡住，验证通过后填入）。
> 后端已可本地运行：生成文案 + 调度 + 发布模块（token 到位即启用）。未配 token 时发布走
> `pending_token` / `dry_run` 安全模式，不会真正发帖。

## 技术栈
- **后端**：Python FastAPI + SQLite（零依赖存储）
- **文案生成**：Ollama 本地 LLM（默认 `llama3.2:1b`，可换更大模型）
- **调度/编排**：n8n（cron 每日 1–2 次）
- **媒体**：Pillow（图片）+ ffmpeg（视频，需另行安装）
- **控制中心**：Flutter Android APK（见 `mobile/`）

## 目录
```
warisan-agent/
├── app/
│   ├── config.py        配置（.env）
│   ├── db.py            SQLite：posts + settings（含 token 持久化）
│   ├── prompts.py       Warisan Aleen 品牌提示词
│   ├── ollama_client.py Ollama 调用 + JSON 容错解析
│   ├── publisher.py     Graph API 发布（token 就绪 / dry-run 安全）
│   ├── media.py         图片/视频处理
│   └── main.py          FastAPI 路由
├── n8n/workflow_publish.json   n8n 每日发帖工作流
├── mobile/              Flutter 控制中心（待建）
├── media/               生成的媒体文件
├── requirements.txt
└── .env.example
```

## 快速开始（后端）
```bash
cd warisan-agent
python -m venv .venv && .venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env          # 按需修改；token 暂留空
python -c "from app import db; db.init_db()"
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

测试生成（需 Ollama 运行且已拉取模型）：
```bash
curl -X POST http://localhost:8000/generate -H 'Content-Type: application/json' -d '{"topic":"rendang ayam"}'
```

## 获取 Token 后
1. `POST /settings/token` 填入 Page/IG 长期访问令牌
2. `POST /settings/dryrun` 设 `{"dry_run": false}`
3. 启动 n8n 导入 `n8n/workflow_publish.json` 并激活

## Token 流程（验证通过后）
OAuth 同意 → 用户短命令牌 → `/me/accounts` 换 Page 令牌 →
`/oauth/access_token?grant_type=fb_exchange_token` 换 60 天长期令牌 → 存入设置。
详见任务档案 `warisan_token_blocker_2026-09-06.md`。
