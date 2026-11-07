# MR. WASHWALA — PHASE 3B: FLUTTER SETUP & ENVIRONMENT AUDIT REPORT

**Project:** Mr. WashWala Laundry Booking Mobile App  
**Date:** October 6, 2026  
**Phase Status:** BLOCKED (Flutter SDK Installation Required on System)  

---

## 1. Environment Audit Results

Per the Phase 3B instructions, an environment check was performed on the macOS development environment:

| Environment Tool | Status | Detection Details | Action Required |
| :--- | :--- | :--- | :--- |
| **Git** | ✅ Installed | `/usr/bin/git` | None |
| **Xcode / Command Line Tools** | ✅ Installed | `/usr/bin/xcodebuild` | Ready for iOS builds |
| **Flutter SDK** | ❌ **Missing** | `flutter: command not found` | Manual installation required by user |
| **Dart SDK** | ❌ **Missing** | `dart: command not found` | Installed automatically with Flutter SDK |
| **Android SDK / Studio** | ⚠️ Not Detected | PATH check returned negative | Install Android Studio & Android SDK |

---

## 2. Project Location Plan

- **Existing Project (Untouched):** `/Users/ajay/Desktop/mrwashwala/mrwashwala`
- **New Mobile App Location (Target):** `/Users/ajay/Desktop/mrwashwala/mrwashwala-mobile`
- **Structure:**
  ```text
  Desktop/mrwashwala/
  ├── mrwashwala/           # Existing React Web + Express Server (UNTOUCHED)
  │   ├── client/
  │   └── server/
  │
  └── mrwashwala-mobile/    # Target Flutter Mobile App (To be initialized)
      ├── android/
      ├── ios/
      ├── lib/
      ├── test/
      └── pubspec.yaml
  ```

---

## 3. Recommended Production Flutter Architecture (`lib/`)

Once Flutter is installed, `mrwashwala-mobile` will be created with the following clean architecture:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart              # MaterialApp entry with Material 3 Theme
│   ├── routes/               # App router & screen paths
│   └── theme/                # Primary color palette, typography & button styles
├── core/
│   ├── constants/            # API endpoints & app constants
│   ├── network/              # HttpClient abstraction for Express API
│   ├── storage/              # Secure token storage
│   └── utils/                # Date/time & currency formatters
├── models/                   # Service, Order, Customer, Address data models
├── services/                 # API Service wrappers (AuthService, OrderService)
├── features/                 # Modular Feature Screens
│   ├── home/                 # Home Screen & Banners
│   ├── services/             # Laundry Services list & customization
│   ├── cart/                 # Cart items & total summary
│   ├── checkout/             # Address, pickup slot & payment selector
│   ├── orders/               # Order history & status tracking
│   ├── auth/                 # OTP Request & Verification
│   └── profile/              # Customer profile & saved addresses
└── widgets/                  # Reusable UI components (Buttons, Inputs, Cards)
```

---

## 4. API Configuration Plan

The mobile application will connect directly to the existing Express backend API via a centralized configuration:

```dart
class ApiConstants {
  // Local Development Base URL
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator
  // static const String baseUrl = 'https://mrwashwala.com/api'; // Production

  static const String services = '$baseUrl/services';
  static const String sendOtp = '$baseUrl/customer/auth/send-otp';
  static const String verifyOtp = '$baseUrl/customer/auth/verify-otp';
  static const String profile = '$baseUrl/customer/profile';
  static const String addresses = '$baseUrl/customer/addresses';
  static const String orders = '$baseUrl/customer/orders';
  static const String reviews = '$baseUrl/customer/reviews';
}
```

---

## 5. Manual Action Required from User

To proceed with Phase 3B Flutter app creation, please install Flutter SDK on your macOS machine:

1. **Download Flutter SDK:**
   Visit [flutter.dev/docs/get-started/install/macos](https://flutter.dev/docs/get-started/install/macos) and download the macOS Flutter SDK (ARM64 / Apple Silicon or Intel).
2. **Extract & Add to PATH:**
   ```bash
   mkdir -p ~/development
   cd ~/development
   unzip ~/Downloads/flutter_macos_*.zip
   export PATH="$PATH:~/development/flutter/bin"
   ```
3. **Verify Installation:**
   Run `flutter doctor` in your terminal to complete Android Studio and SDK setup.
4. **Resume Phase 3B:** Once `flutter --version` returns successfully, tell me to proceed with project initialization!

---

## 6. Safety Audit Confirmation

- Existing website (`client/`): **UNTOUCHED (0 changes)**
- Existing backend (`server/`): **UNTOUCHED (0 changes)**
- MongoDB Database: **UNTOUCHED (0 changes)**
- GitHub/Production: **NOT PUSHED / NOT DEPLOYED**
