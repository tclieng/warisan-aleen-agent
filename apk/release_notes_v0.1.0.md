# Warisan Aleen AI Agent APK — Release Notes

## v0.1.0 (2026-09-06)

**Download**: `WarisanAleenAgent-v0.1.0.apk` (20.9 MB, release-signed, Android 5.0+)

### What's in this build
- **Material 3 theme**: Kampung-green (`#14301C`) + cream-rice secondary
- **4-tab bottom navigation**: 概览 / 生成 / 队列 / 设置
- **Dashboard**: real-time backend status, post counts, FB/IG asset IDs
- **Generate**: tap to ask backend `POST /generate` with topic + platform
- **Queue**: list scheduled/draft posts, publish-now action
- **Settings**: edit backend base URL (10.0.2.2 for emulator / LAN IP for real device), paste Meta token, toggle DRY_RUN

### How to use
1. **Install**: `adb install -r WarisanAleenAgent.apk`
2. **Open app** → 概览 (Dashboard) should show backend connection
3. **Settings tab** → enter your computer's LAN IP (e.g. `http://192.168.1.10:8000`)
4. Make sure phone and PC are on same WiFi
5. On PC: `cd warisan-agent && python -m uvicorn app.main:app --host 0.0.0.0 --port 8000`

### Known limitations
- **Meta token NOT included** — must be obtained via Meta Business Verification + Advanced Access submission
- **Currently**: `/posts/{id}/publish` will report `pending_token` if no token set
- **DRY_RUN=true** is default — safe mode even if token is added later

### Build environment
- Flutter 3.22.2 stable
- Android compileSdk 36, minSdk 21
- Built on Windows 10, JDK 17 (Temurin)

### Roadmap (v0.2.0+)
- [ ] API retry with backoff (in code, blocked by 4GB RAM build OOM)
- [ ] Pull-to-refresh on dashboard
- [ ] Image upload for posts
- [ ] Push notifications for failed publishes
- [ ] OAuth flow inside app (deep link callback)