# Mr. WashWala
# Phase 7 — Production API Configuration Preparation

## Current Development API

`http://10.0.2.2:5000/api`

## Production API

NOT PROVIDED YET (Awaiting Hostinger deployment and domain configuration from Sir)

## Centralized API Configuration

`PASS`
- Configured in `lib/core/config/api_config.dart`
- All endpoint getters (`services`, `sendOtp`, `verifyOtp`, `profile`, `addresses`, `orders`, `reviews`) derive dynamically from `ApiConfig.baseUrl`
- Zero hardcoded base URLs in repository classes, controllers, or screens

## Dart Define Support

`PASS`
- `ApiConfig.baseUrl` is defined using `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5000/api')`
- Seamlessly accepts production build URL via `--dart-define=API_BASE_URL=https://<REAL_HOSTINGER_API>/api`

## Hardcoded API URLs

`NONE`
- Full codebase search confirmed 0 hardcoded backend URLs in screens, controllers, repositories, services, or models

## Authentication Configuration

`PASS`
- Centralized `ApiClient` automatically injects `Authorization: Bearer <token>` for all authenticated requests
- Zero tokens or sensitive credentials printed in console logs

## HTTPS Readiness

`PASS`
- `ApiClient` uses standard Dart `Uri.parse()` with `http.Client`, natively supporting both `http://` (development) and `https://` (production)
- Zero insecure SSL bypasses or disabled certificate validations

## Android INTERNET Permission

`PASS`
- `android.permission.INTERNET` and `android.permission.ACCESS_NETWORK_STATE` declared in `android/app/src/main/AndroidManifest.xml`

## Cleartext HTTP

`ENABLED FOR DEVELOPMENT`
- `android:usesCleartextTraffic="true"` configured in `AndroidManifest.xml` to allow cleartext HTTP communication with local Android emulator (`http://10.0.2.2:5000/api`)

## Production Cleartext Review

`REQUIRED BEFORE RELEASE`
- `android:usesCleartextTraffic="true"` should be reviewed and removed once the production HTTPS URL is configured

## Release Configuration

`PASS / NEEDS REVIEW`
- Namespace & Application ID: `com.mrwashwala.mrwashwala_mobile`
- Version & Version Code: Synced with `pubspec.yaml`
- Release signing currently mapped to `debug` keystore for local `--release` testing; production keystore signing configuration required when publishing to Google Play Store

## Flutter Analyze

`0 ERRORS, 0 WARNINGS (9 INFO)`

## Flutter Tests

`45 / 45 TESTS PASSED`

## Android Build

`PASS` (`✓ Built build/app/outputs/flutter-apk/app-debug.apk`)

## Development Emulator

`PASS` (`emulator-5554` connected to `http://10.0.2.2:5000/api`)

## Backend Changes

NONE

## Website Changes

NONE

## MongoDB Changes

NONE

## GitHub Push

NO

## Deployment

NOT DONE

## Production URL

WAITING FOR SIR

## Final Status

READY FOR PRODUCTION URL CONFIGURATION
