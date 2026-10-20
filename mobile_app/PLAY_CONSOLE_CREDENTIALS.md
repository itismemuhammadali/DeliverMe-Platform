# DeliverMee — Credentials & Play Console Reference

> Keep this file secure. Do NOT commit to version control.

---

## Google Play Console

| Field | Value |
|-------|-------|
| Account Name | DeliverMee Tech Corp |
| Account Type | Organization |
| Account ID | 7858355087722055391 |
| Console URL | https://play.google.com/console/u/0/developers/7858355087722055391 |

---

## App Info

| Field | Value |
|-------|-------|
| App Name | DeliverMee |
| Package Name | `com.delivermee.app` |
| Version | 1.0.7 (versionCode: 1) |
| Status | Draft |
| AAB Location | `build/app/outputs/bundle/release/app-release.aab` |

---

## Android Keystore (Release Signing)

| Field | Value |
|-------|-------|
| Keystore File | `android/app/upload-keystore.jks` |
| Key Alias | `delivermee` |
| Store Password | `delivermee2026` |
| Key Password | `delivermee2026` |
| Algorithm | RSA 2048-bit |
| Validity | 10,000 days (~27 years) |
| Created | Jul 26, 2026 |

**CRITICAL:** Back up `upload-keystore.jks` — losing it means you can never update the app again.

---

## Firebase

| Field | Value |
|-------|-------|
| Project ID | `delivermee-12c26` |
| Project Number | `648361658719` |
| Storage Bucket | `delivermee-12c26.firebasestorage.app` |
| Firebase Console | https://console.firebase.google.com/project/delivermee-12c26 |

### Android (google-services.json)
| Field | Value |
|-------|-------|
| App ID | `1:648361658719:android:ff17c3b5fe3254da088eea` |
| API Key | `AIzaSyC-aMZUlqHBmmhHBolum72-OHmK1BBiBXk` |
| Package | `com.delivermee.app` |

### iOS (GoogleService-Info.plist)
| Field | Value |
|-------|-------|
| App ID | `1:648361658719:ios:dac49540361fd2e5088eea` |
| API Key | `AIzaSyC3fedUM_wTX5hL3p31Q89LH2HSB5D8gW8` |
| Bundle ID | `com.delivermee.app` |
| GCM Sender ID | `648361658719` |

---

## Google Maps API

| Field | Value |
|-------|-------|
| API Key | `AIzaSyBaibQR5H_xFkers-GWAqrNA0xr1SScaKA` |
| Config Location | `android/local.properties` (line: `MAPS_API_KEY=...`) |

---

## Stripe

| Field | Value |
|-------|-------|
| Config Method | Firebase Remote Config (`stripe_public_key`) |
| Stripe Dashboard | https://dashboard.stripe.com |

Stripe keys are stored in Firebase Remote Config, not in code. Check the Firebase Console under Remote Config for the actual keys.

---

## Store Listing Checklist (Google Play Console)

When filling out the store listing, you'll need:

- [ ] **App name**: DeliverMee
- [ ] **Short description** (80 chars max)
- [ ] **Full description** (4000 chars max)
- [ ] **App icon**: 512x512 PNG
- [ ] **Feature graphic**: 1024x500 PNG
- [ ] **Phone screenshots**: Min 2, PNG or JPEG, 16:9 or 9:16 ratio
- [ ] **Tablet screenshots** (optional but recommended)
- [ ] **Privacy policy URL**: Required (host this somewhere)
- [ ] **Content rating**: Fill out IARC questionnaire
- [ ] **Target audience**: Declare age groups
- [ ] **Data safety**: Declare data collection (Firebase, location, camera, contacts, etc.)

---

## Data Safety Declaration (what the app collects)

| Data Type | Collected | Purpose |
|-----------|-----------|---------|
| Location | Yes | Delivery tracking, route navigation |
| Camera/Photos | Yes | Profile photos, delivery proof |
| Personal Info | Yes | Name, email, phone (auth) |
| Payment Info | Yes | Stripe payment processing |
| Device IDs | Yes | Firebase analytics, crashlytics |
| App Activity | Yes | Firebase analytics |

---

## Build Commands

```bash
# Build release AAB
flutter build appbundle --release

# Output location
build/app/outputs/bundle/release/app-release.aab
```

---

## Useful Links

| Resource | URL |
|----------|-----|
| Google Play Console | https://play.google.com/console |
| Firebase Console | https://console.firebase.google.com/project/delivermee-12c26 |
| Stripe Dashboard | https://dashboard.stripe.com |
| Android Developer Verification | https://play.google.com/console/u/0/developers/7858355087722055391/developer-verification |
