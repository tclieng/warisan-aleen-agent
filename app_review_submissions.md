# App Review — Use Case Submission Drafts

**App**: Warisan Aleen (ID: 1059118460322383)
**Business**: Warisan Aleen Sdn Bhd (ID: 1070676568896535)
**Submitter**: CL Tan (kraf.manager@gmail.com)

---

## 1. Manage everything on your Page

**Why are you requesting this use case?**

Warisan Aleen is a Malaysian kampung-style food brand that operates a single Facebook Page (Warisan Aleen, Page ID: 1369264899593189). We need automated access to publish daily marketing content (1–2 posts per day) to our own Page, including:

- Text posts featuring traditional recipes and product highlights
- Photo captions for food product launches
- Promotional posts for seasonal menu items (Hari Raya, Malaysia Day, etc.)

Content is generated in Bahasa Malaysia and English, reflecting our dual-language audience. All posts are reviewed by a human moderator (the Page admin, CL Tan) before publishing. We never post on behalf of other Pages, other businesses, or third parties — only our own single brand Page.

**How does your app use this use case?**

Our internal AI Marketing Agent generates draft captions based on product inputs (e.g. "Nasi Lemak", "Rendang") and tone (promotional, educational, festive). Drafts are stored in a local SQLite database, queued for human review, then published via the Graph API to our Page. The app runs on a local FastAPI backend and is operated solely by the Page admin from a Windows desktop. No third-party users, no multi-tenant access, no scheduling across Pages. The system is built for a single-business, single-Page workflow.

**Verification steps:**
1. Confirm Page admin role: GET /me/accounts → expect Page 1369264899593189
2. Confirm token scope: debug_token → expect pages_show_list, pages_read_engagement, pages_manage_posts
3. Test publish: POST /{page-id}/feed with message → expect id (post created)

---

## 2. Manage messaging & content on Instagram

**Why are you requesting this use case?**

Our Instagram account @warisanaleen (Business Account ID: 17841425967343775) mirrors the Facebook Page content — we publish the same food/lifestyle captions to both platforms. We need to programmatically publish Instagram media (image posts with captions) to maintain a consistent posting schedule (1–2 posts per day).

**How does your app use this use case?**

The same AI Marketing Agent described above generates captions, then publishes to both FB Page and IG. For Instagram, the flow is:
1. Generate caption (BM/EN)
2. Upload image to a local hosting path or use already-uploaded media
3. POST to /{ig-account-id}/media with image_url + caption
4. POST to /{ig-account-id}/media_publish to publish

All content is pre-reviewed by the Page admin. Only our own IG account is published to. No third-party access.

**Verification steps:**
1. Confirm IG business account: GET /17841425967343775?fields=id,username → expect @warisanaleen
2. Confirm token scope: debug_token → expect instagram_basic, instagram_content_publish, instagram_manage_insights
3. Test publish: POST /17841425967343775/media → expect creation id

---

## Submission checklist before you click Submit

On the Meta Use Cases page:
- [ ] Privacy Policy URL is set and reachable: https://marketsocialnow.xyz/ (already configured)
- [ ] App icon uploaded (Meta requires a 1024x1024 icon)
- [ ] Business verification completed (already done)
- [ ] Each use case above has the corresponding justification text pasted in
- [ ] All checklist items in "App customization and requirements" show ✓

After submission:
- Expected review time: 1–5 business days
- You'll receive an email + Alert Inbox notification when approved
- Once approved, regenerate your User Token (it picks up new scopes automatically on next OAuth)

---

## What I'll do once Meta approves

1. Re-run OAuth to get fresh User Token with new scopes
2. Exchange for Page Token via /me/accounts
3. Update backend via POST /settings/token
4. Set dry_run=false
5. Test one publish to FB Page and one to Instagram
6. Set up n8n cron to call /publish/due every hour