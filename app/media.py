"""媒体处理工具。

图片：用 Pillow 做封面缩放 + 留白（IG 推荐 1080x1080 / 1080x1350）。
视频：若系统装有 ffmpeg 则提供缩放/转码；否则提示需安装 ffmpeg。
零月成本、纯本地。
"""
from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from app.config import cfg


def ffmpeg_available() -> bool:
    return shutil.which("ffmpeg") is not None


def _fit_cover(im: Image.Image, size: tuple[int, int]) -> Image.Image:
    """cover 缩放并居中裁剪到目标尺寸。"""
    tw, th = size
    sw, sh = im.size
    scale = max(tw / sw, th / sh)
    nw, nh = int(sw * scale), int(sh * scale)
    im = im.resize((nw, nh), Image.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return im.crop((left, top, left + tw, top + th))


def prepare_image(src: str | Path, dst: str | Path, size: tuple[int, int] = (1080, 1080)) -> Path:
    """缩放/裁剪图片为社媒尺寸，保存到 dst。返回 dst。"""
    im = Image.open(src).convert("RGB")
    im = _fit_cover(im, size)
    dst = Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, "JPEG", quality=88)
    return dst


def add_caption(src: str | Path, dst: str | Path, text: str, size: tuple[int, int] = (1080, 1080)) -> Path:
    """在图片底部叠加半透明条 + 文案（ Kampung 风：深绿底奶油字）。"""
    im = Image.open(src).convert("RGB")
    im = _fit_cover(im, size)
    draw = ImageDraw.Draw(im, "RGBA")
    bar_h = int(size[1] * 0.22)
    draw.rectangle([0, size[1] - bar_h, size[0], size[1]], fill=(20, 48, 28, 200))
    try:
        font = ImageFont.truetype("arial.ttf", 42)
    except IOError:
        font = ImageFont.load_default(42)
    # 简单换行
    lines, cur = [], ""
    for word in text.split():
        if draw.textlength(cur + " " + word, font=font) > size[0] - 60 and cur:
            lines.append(cur)
            cur = word
        else:
            cur = (cur + " " + word).strip()
    if cur:
        lines.append(cur)
    y = size[1] - bar_h + 20
    for ln in lines[:3]:
        draw.text((30, y), ln, fill=(245, 235, 210), font=font)
        y += 50
    dst = Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, "JPEG", quality=88)
    return dst


def ffmpeg_resize_video(src: str | Path, dst: str | Path, size: str = "1080:1920") -> Path:
    """用 ffmpeg 缩放视频（用于 Reels/Shorts）。无 ffmpeg 抛 RuntimeError。"""
    if not ffmpeg_available():
        raise RuntimeError("ffmpeg 未安装，无法处理视频。请安装 ffmpeg 后重试。")
    dst = Path(dst)
    dst.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(src), "-vf",
         f"scale={size}:force_original_aspect_ratio=decrease,pad={size}:(ow-iw)/2:(oh-ih)/2",
         "-c:a", "copy", str(dst)],
        check=True, capture_output=True,
    )
    return dst
