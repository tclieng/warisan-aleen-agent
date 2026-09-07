# Warisan Aleen — Meta Token 阻塞分析 & 解法路径

**生成时间**: 2026-09-06 18:00 GMT+8
**核心问题**: `pages_manage_posts` 权限未注册，Facebook Page 发帖链路阻塞

---

## ✅ 已完成的工作

| 项目 | 状态 |
|------|------|
| Meta Business 账号 (ID: 1070676568896535) | ✅ 已就绪 |
| Warisan Aleen Facebook Page (ID: 1369264899593189) | ✅ 已就绪 |
| Warisan Aleen Instagram (ID: 17841425967343775, @warisanaleen) | ✅ 已就绪 |
| Warisan Aleen App (ID: 1059118460322383) | ✅ 已创建并通过 Business 验证 |
| CL Tan User Token (237字符, EAAPD...) | ✅ 已获取，有效期到 2027-01-05 |
| Warisan Aleen Page Token | ✅ 已获取 |
| kampungposter System User | ✅ 已创建 |
| Flutter Agent APK | ✅ 已构建 (19.9MB) |

---

## ❌ 阻塞点

**根因**: `pages_manage_posts` 权限在 App 中未注册/未获批。

具体表现：
- **Facebook Page 发帖**：Page Token + User Token 都返回 Error 200："需要 `pages_manage_posts` 权限"
- **Instagram 发帖**：完全无法访问 IG API（Error 100: Object does not exist）
- **OAuth 流程**：加入 `pages_manage_posts` → 报 "Invalid Scopes"（权限未在 App 注册）

---

## 🔑 关键文件

- **warisan-agent/app/main.py** — FastAPI 后端（已支持 FB/IG 发帖端点，token 待填入）
- **warisan-agent/mobile/** — Flutter APK 源码（需填入 backend URL）

---

## ✅ 解决方案（需您手动操作）

### 方案 A（推荐）：提交 App Review（30分钟）

这是 Meta 官方通道，唯一能解锁 `pages_manage_posts` 的方法。

**步骤**：
1. 登录 https://developers.facebook.com
2. 进入 **My Apps → Warisan Aleen**
3. 左侧菜单 → **App Review for Advanced Access**
4. 点击 **Request Permissions or Features**
5. 搜索并添加：
   - `pages_manage_posts` — 用于 FB Page 发帖
   - `instagram_basic` — 用于读取 IG 账号信息
   - `instagram_content_publish` — 用于 IG 发帖
6. 填写用途说明（可参考下面模板）
7. 提交

**用途说明模板**：
```
Warisan Aleen is a Malaysian kampung-style food brand. 
This app automatically generates and publishes marketing content 
(Bahasa Malaysia and English) to our Facebook Page and Instagram 
account (@warisanaleen) on a daily basis (1-2 posts per day).
The content includes food product features, traditional recipes, 
and promotional material.
```

**审核时间**：Meta 通常 1-5 个工作日审核通过。审核通过后，当前 token 自动获得新权限。

### 方案 B：把 CL Tan 加为 Page 管理员

如果 Warisan Aleen Page 在创建时 CL Tan 不是管理员：
1. 打开 https://business.facebook.com → 切换到 Warisan Aleen Business
2. 进入 **Settings → People and Assets** 或 **Pages**
3. 找到 Warisan Aleen Page → Assign people → 添加 CL Tan 为管理员

这样 CL Tan 的个人账号就能通过 `/me/accounts` 看到 Warisan Aleen Page。

---

## 📋 后端 token 填写

审核通过后，我来帮您更新后端 token：

**需要填入 `warisan-agent/app/main.py`**：
- `FB_PAGE_TOKEN` — Warisan Aleen Page Access Token（审核通过后刷新）
- `IG_ACCOUNT_ID` — `17841425967343775`
- `IG_ACCESS_TOKEN` — 审核通过后重新 OAuth 获取

---

## 📱 移动端 APK

Flutter Agent APK 已构建：`C:\Users\MK-User\Desktop\WarisanAleenAgent.apk` (19.9MB)

待 token 解决后，backend URL 填入 `http://10.0.2.2:8000`（Android Studio 模拟器）或局域网 IP（真机），即可连接后端。
