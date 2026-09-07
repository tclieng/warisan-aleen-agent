# Warisan Aleen — Flutter 控制中心

Android APK 控制中心：连接本地 FastAPI 后端，查看概览、生成双语文案、管理帖子队列、配置 Token 与演练模式。

## 页面
- **概览**：后端状态 / Token / 模型 / 帖子统计 / FB·IG 资产 ID
- **生成**：输入主题 → 调 `/generate` 产出 BM+EN 文案
- **队列**：帖子列表，逐条/批量发布到点帖子（`/publish/due`）
- **设置**：后端地址、Meta Access Token、DRY_RUN 开关

## 构建（需 git + Android SDK + 足够内存）
```bash
cd mobile
flutter pub get
flutter build apk --debug
# 安装：flutter install
```
> 模拟器访问宿主机后端用 `http://10.0.2.2:8000`；真机用电脑局域网 IP。
> 当前宿主机仅 4GB RAM，无法在此编译 APK；代码已就绪，环境就绪即可构建。
