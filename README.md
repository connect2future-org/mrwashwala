# Mr. WashWala

Mr. WashWala is an end-to-end digital laundry booking and operations management platform. The system connects retail laundry customers and franchise branch operations through modern digital interfaces (responsive web and cross-platform mobile apps) backed by a centralized Node.js/Express API and MongoDB database.

---

## System Architecture

```text
                 MR. WASHWALA
                       |
              -------------------
              |                 |
           CLIENT             SERVER
              |                 |
       --------------       Node.js /
       |            |       Express API
    Website      Mobile         |
    React/Vite   Flutter        |
       |            |           |
       -------- API -------------
                       |
                    MongoDB
```

### Component Roles

1. **Website (`client/website`)**: React + Vite Single Page Application (SPA). Provides the public-facing customer portal, branch locator, service catalog, interactive location picker for checkout, and administrative dashboard for branch managers.
2. **Mobile Application (`client/mobile`)**: Single Flutter codebase supporting Android and iOS. Delivers customer onboarding via phone OTP, service browsing, real-time cart calculation, checkout with scheduling, saved delivery addresses, dynamic reviews, and order tracking.
3. **Backend API (`server`)**: Node.js & Express RESTful API server connected to MongoDB. Handles authentication, customer records, dynamic service pricing, order creation and status tracking, workflow processing tickets, reviews, and admin analytics.
4. **Documentation Hub (`client/docs`)**: Centralized repository containing phase reports, system architecture diagrams, API research/audits, and UI verification screenshots.

---

## Repository Structure

The project maintains two primary top-level folders:

```text
mrwashwala/
│
├── client/
│   │
│   ├── website/                     # React / Vite customer website & admin portal
│   │   ├── src/                     # React components, pages, hooks, contexts
│   │   ├── public/                  # Static assets, logos, videos
│   │   ├── package.json             # Website npm dependencies & scripts
│   │   └── vite.config.js           # Vite build configuration
│   │
│   ├── mobile/                      # Flutter mobile app (Android & iOS)
│   │   ├── lib/                     # Dart application source (Clean Architecture)
│   │   ├── android/                 # Native Android configuration & launcher icons
│   │   ├── ios/                     # Native iOS workspace configuration
│   │   ├── test/                    # Unit, widget, and repository test suites
│   │   ├── assets/                  # Mobile branding, mascot, and logos
│   │   └── pubspec.yaml             # Flutter dependencies & assets config
│   │
│   └── docs/                        # Complete project documentation & assets
│       ├── phase-reports/           # Phased reports & audits (Phases 1 - 9A)
│       ├── architecture/            # Architecture specifications & integration guides
│       ├── api-research/            # API contracts & data source audits
│       ├── website-screenshots/     # Web screenshots & UI captures
│       └── mobile-screenshots/      # Mobile screenshots & launcher icon previews
│
├── server/                          # Node.js / Express backend REST API
│   ├── config/                      # Database & workflow configurations
│   ├── middleware/                  # Admin and Customer JWT authentication middleware
│   ├── models/                      # MongoDB Mongoose schemas (Order, Customer, Service, etc.)
│   ├── routes/                      # Express route controllers (/api/*)
│   ├── scripts/                     # Database seed & migration utilities
│   ├── services/                    # Payment provider adapter abstractions
│   ├── server.js                    # Express application entrypoint
│   └── package.json                 # Backend npm dependencies & scripts
│
├── README.md                        # Root project guide (this document)
├── .gitignore                       # Repository-wide Git ignore rules
└── netlify.toml                     # Web deployment build & redirect configuration
```

---

## API Communication Architecture

Both the web application and mobile application communicate with the exact same Node.js/Express backend API:

### 1. Website ↔ Backend Communication
- Configured in [`client/website/src/api/api.js`](client/website/src/api/api.js) via Axios.
- Resolves `VITE_API_URL` environment variable in production, defaulting to `http://localhost:5000` during local development.
- Interacts with public endpoints (`/api/services`, `/api/reviews`, `/api/orders`) and admin endpoints (`/api/admin/*`, `/api/analytics`, `/api/inventory`).

### 2. Mobile (Android & iOS) ↔ Backend Communication
- Configured in [`client/mobile/lib/core/config/api_config.dart`](client/mobile/lib/core/config/api_config.dart).
- Automatically adapts base URLs according to the runtime platform:
  - **Android Emulator**: `http://10.0.2.2:5000/api` (routes to host machine `localhost:5000`)
  - **iOS Simulator / Localhost**: `http://127.0.0.1:5000/api`
  - **Custom Base URL**: Configurable at launch via `--dart-define=API_BASE_URL=<URL>`
- Secure customer authentication with Bearer JWT tokens stored in `flutter_secure_storage`.
- Customer routes include `/api/customer/auth`, `/api/customer/profile`, `/api/customer/addresses`, `/api/customer/orders`, and `/api/customer/reviews`.

---

## Getting Started & Basic Commands

### Prerequisites
- **Node.js**: >= 18.x
- **Flutter SDK**: >= 3.13.5 / Dart >= 3.13.5
- **MongoDB**: Local MongoDB instance or MongoDB Atlas connection URI

---

### 1. Backend Server (`server/`)

```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Configure environment variables
# Copy server/.env.example to server/.env and provide PORT and MONGO_URI
cp .env.example .env

# Run development server (with nodemon reload)
npm run dev

# Run in production mode
npm start

# Seed initial database services & admin user
npm run seed
```

---

### 2. Website Frontend (`client/website/`)

```bash
# Navigate to website directory
cd client/website

# Install dependencies
npm install

# Start Vite local development server (default: http://localhost:5173)
npm run dev

# Build production bundle (outputs to client/website/dist/)
npm run build

# Preview production build locally
npm run preview

# Run linter
npm run lint
```

---

### 3. Mobile Application (`client/mobile/`)

```bash
# Navigate to mobile directory
cd client/mobile

# Fetch Flutter dependencies
flutter pub get

# Run static analysis
flutter analyze

# Execute test suite (120+ unit and widget tests)
flutter test

# Build Android Debug APK
flutter build apk --debug
# Output: client/mobile/build/app/outputs/flutter-apk/app-debug.apk

# Launch on connected Android emulator or device
flutter run
```

---

## Documentation Index

All project documentation is consolidated under [`client/docs/`](client/docs/README.md):

- **[Phased Development Reports](client/docs/phase-reports/README.md)**: Sequential reports detailing Phases 1 through 9A.
- **[System Architecture](client/docs/architecture/README.md)**: Dynamic reviews architecture, location picker integration, and system blueprints.
- **[API Research & Contracts](client/docs/api-research/README.md)**: Customer order history data source audit, endpoint specifications, and integration contracts.
- **[Mobile Screenshots & Assets](client/docs/mobile-screenshots/README.md)**: Mobile UI captures, customer flow verification, and launcher icon designs.
- **[Website Screenshots](client/docs/website-screenshots/README.md)**: Website responsive UI captures and design audits.

