# AWS Deep Link Deployment Guide for app.bigtv24x7.com

This folder contains the pre-configured verification files required for Android App Links and iOS Universal Links for **app.bigtv24x7.com**.

---

## 1. Files in this Directory

| File | Target Server URL | Content-Type Header |
|---|---|---|
| `.well-known/assetlinks.json` | `https://app.bigtv24x7.com/.well-known/assetlinks.json` | `application/json` |
| `.well-known/apple-app-site-association` | `https://app.bigtv24x7.com/.well-known/apple-app-site-association` | `application/json` |

---

## 2. Configuration Details Extracted from Project

- **Android Package Name:** `com.chotanews`
- **Android Release SHA-256 (from `android/app/key.jks`):**
  `91:F9:BB:B7:8C:01:A8:49:6B:32:78:88:A1:9C:21:AB:8F:1D:BA:19:DE:77:06:63:DD:78:E4:C5:A9:05:D3:06`
- **Android Debug SHA-256 (for local development testing):**
  `49:54:FA:54:4A:69:B0:D2:DF:7E:AE:CC:0F:8A:AB:7C:71:35:FB:B1:F7:A2:9D:D6:E5:90:40:EB:84:1E:36:E4`
- **iOS Team ID:** `74NBJBC965`
- **iOS Bundle ID:** `com.chotanewstelugu.app`
- **Combined Apple App ID:** `74NBJBC965.com.chotanewstelugu.app`

*(Note: If you use Google Play App Signing, also add the SHA-256 fingerprint found in Google Play Console -> Setup -> App Integrity -> App signing key certificate).*

---

## 3. How to Deploy to AWS S3 & CloudFront

1. **Upload to S3 Bucket:**
   Upload the `.well-known` folder into your S3 bucket serving `app.bigtv24x7.com`:
   ```bash
   aws s3 cp .well-known/ s3://your-bucket-name/.well-known/ --recursive --content-type application/json
   ```

2. **Crucial S3 Metadata Setting:**
   - Both files **MUST** have the `Content-Type` metadata header set to: `application/json`.
   - The file `apple-app-site-association` **MUST NOT** have any file extension (do not add `.json`).

3. **CloudFront Behaviors:**
   - Add a Cache Behavior for path pattern `/.well-known/*`:
     - Allowed HTTP Methods: `GET, HEAD`
     - Viewer Protocol Policy: `Redirect HTTP to HTTPS`
     - Compress Objects Automatically: `Yes`

4. **Web Fallback (Redirect to App Store when opened on Web/Desktop):**
   - For paths like `/live`, `/games*`, `/events*`, `/individualPage*`, configure your web server or CloudFront Function/Lambda@Edge to redirect unhandled web browser visits to:
     `https://play.google.com/store/apps/details?id=com.chotanews`
