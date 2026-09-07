"""Warisan Aleen 品牌文案模板库（Ollama 不可用时的兜底生成器）。

当本地 Ollama 因内存/资源无法加载模型时，用这套 kampung 风模板保证 Agent 仍能产出
符合品牌调性的 Bahasa Malaysia + English 双语文案。模板化内容稳定、零资源消耗。
"""
from __future__ import annotations

import random

# 每条约：title / caption_bm / caption_en / theme
# {dish} 会被替换为主题中的菜品词（否则用默认 "lauk kampung"）。
_TEMPLATES = [
    {
        "title": "Resipi Warisan",
        "caption_bm": "Tak ada yang mengubat rindu seperti hidangan kampung yang dimasak dengan sepenuh hati. {dish} kami diwarnai rempah tradisional dan resepi turun-temurun. Mari rasa keasliannya! #WarisanAleen #MasakanKampung",
        "caption_en": "Nothing soothes the soul like a homely kampung dish cooked with love. Our {dish} is infused with traditional spices and heritage recipes passed down generations. Taste the authenticity! #WarisanAleen #KampungFood",
        "theme": "heritage",
    },
    {
        "title": "Lauk Pagi Ini",
        "caption_bm": "Pagi yang sempurna bermula dengan {dish} yang masih panas dan harum. Warisan Aleen sedia hidangan untuk keluarga anda. Selamat menjamu selera! #Sarapan #WarisanAleen",
        "caption_en": "A perfect morning starts with warm, fragrant {dish}. Warisan Aleen prepares it fresh for your family. Selamat menjamu selera — enjoy your meal! #Breakfast #WarisanAleen",
        "theme": "breakfast",
    },
    {
        "title": "Rasa Kampung",
        "caption_bm": "Rasa yang membawa anda pulang ke desa. {dish} kami dibuat tanpa pewarna dan pengawet — asli seperti dulu. Dapatkan hari ini! #MakananAsli #WarisanAleen",
        "caption_en": "A taste that brings you home to the village. Our {dish} is made without artificial colouring or preservatives — just like the old days. Order today! #AuthenticFood #WarisanAleen",
        "theme": "authentic",
    },
    {
        "title": "Weekend Treat",
        "caption_bm": "Hujung minggu lebih manis dengan {dish} dari Warisan Aleen. Kongsi kegembiraan ini bersama orang tersayang. #HujungMinggu #WarisanAleen",
        "caption_en": "Weekends are sweeter with {dish} from Warisan Aleen. Share this joy with your loved ones. #WeekendVibes #WarisanAleen",
        "theme": "weekend",
    },
]


def _dish_from_topic(topic: str) -> str:
    t = (topic or "").strip().lower()
    if not t:
        return "lauk kampung"
    # 取首个有意义的词作为菜品名
    return t.split()[0]


def template_post(topic: str = "") -> dict:
    """从模板库生成一篇帖子（Ollama 兜底）。"""
    t = random.choice(_TEMPLATES)
    dish = _dish_from_topic(topic)
    return {
        "title": t["title"],
        "caption_bm": t["caption_bm"].format(dish=dish),
        "caption_en": t["caption_en"].format(dish=dish),
        "theme": t["theme"],
        "source": "template",
    }
