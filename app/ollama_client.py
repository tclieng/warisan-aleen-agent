"""Ollama 本地 LLM 客户端：生成 Warisan Aleen 双语文案。

使用 Ollama 的 /api/chat 接口（OpenAI 兼容 /api/chat）。
模型可在 .env 的 OLLAMA_MODEL 配置；返回结构化 JSON 并做容错解析。
"""
from __future__ import annotations

import json
import re
from typing import Optional

import httpx

from app.config import cfg
from app.prompts import build_messages


class OllamaError(RuntimeError):
    pass


def _extract_json(text: str) -> dict:
    """从模型输出中尽量解析出 JSON（容错：剥离 ```json 围栏、找首个 {...}）。"""
    text = text.strip()
    # 去掉可能的 markdown 代码围栏
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```$", "", text)
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # 退路：截取首个 { 到末个 }
    start, end = text.find("{"), text.rfind("}")
    if start != -1 and end != -1 and end > start:
        try:
            return json.loads(text[start : end + 1])
        except json.JSONDecodeError:
            pass
    raise OllamaError(f"无法解析模型输出为 JSON: {text[:200]}")


def generate_post(topic: str = "") -> dict:
    """调用 Ollama 生成一篇帖子，返回 {title, caption_bm, caption_en, theme}。"""
    payload = {
        "model": cfg.OLLAMA_MODEL,
        "messages": build_messages(topic),
        "stream": False,
        "options": {"temperature": 0.8, "top_p": 0.9},
    }
    try:
        resp = httpx.post(
            f"{cfg.OLLAMA_BASE_URL}/api/chat",
            json=payload,
            timeout=20.0,
        )
        resp.raise_for_status()
        data = resp.json()
        content = data.get("message", {}).get("content", "")
        if not content:
            raise OllamaError("Ollama 返回空内容")
        return _extract_json(content)
    except httpx.HTTPError as e:
        raise OllamaError(f"Ollama 请求失败 ({cfg.OLLAMA_BASE_URL}): {e}")
    except KeyError as e:
        raise OllamaError(f"Ollama 响应格式异常: {e}")


def list_local_models() -> list[str]:
    try:
        resp = httpx.get(f"{cfg.OLLAMA_BASE_URL}/api/tags", timeout=10.0)
        resp.raise_for_status()
        return [m["name"] for m in resp.json().get("models", [])]
    except httpx.HTTPError:
        return []
