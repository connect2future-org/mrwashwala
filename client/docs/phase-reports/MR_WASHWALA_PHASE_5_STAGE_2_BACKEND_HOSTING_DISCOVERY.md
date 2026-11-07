# Mr. WashWala
# Phase 5 Stage 2 — Backend & Hosting Discovery

## 1. Project Structure

The Mr. WashWala codebase consists of the following components:

- **`server/`**: Node.js / Express REST API backend server with Mongoose models, authentication, order management, customer routes, and payment architecture.
  - Contains `package.json`, `server.js`, `config/`, `middleware/`, `models/`, `routes/`, `services/`, and `.env` / `.env.example`.
- **`client/`**: React web application & Admin dashboard built with Vite, React 19, and TailwindCSS v4.
  - Contains `package.json`, `vite.config.js`, `index.html`, `public/`, `src/`, and `.env.example`.
- **`mrwashwala-mobile/`**: Flutter mobile application (located in sibling directory `/Users/ajay/Desktop/mrwashwala/mrwashwala-mobile`).
  - Contains `pubspec.yaml`, `android/`, `ios/`, `lib/`, `test/`.
- **Deployment Files**:
  - `netlify.toml` in workspace root configured for building `client/` frontend (`base = "client"`, `command = "npm run build"`, `publish = "dist"`).
  - No Dockerfiles or docker-compose files present in the repository.

---

## 2. Backend

Backend:
Node.js / Express

Entry:
`server/server.js`

Start command:
`npm start` (`node server.js`) or `npm run dev` (`nodemon server.js`)

Port:
`5000` (configurable via `process.env.PORT`)

Details:
- Node.js Version Requirement: Node.js 18+ recommended (ES Modules `"type": "module"`).
- Express Version: `^4.19.2`
- Host Binding: Standard port listener (`app.listen(PORT)`).
- API Base Structure: `/api/*`
- Authentication: JWT authentication (`jsonwebtoken` 9.0.2 & `bcryptjs` 2.4.3).
- Customer APIs: `/api/customer/auth`, `/api/customer/profile`, `/api/customer/addresses`, `/api/customer/orders`, `/api/customer/reviews`.
- Order APIs: `/api/orders`, `/api/walkin-orders`, `/api/customer/orders`.
- Review APIs: `/api/reviews`, `/api/customer/reviews`.
- Admin APIs: `/api/auth`, `/api/admin`, `/api/processing`, `/api/revenue`, `/api/inventory`, `/api/expenses`, `/api/analytics`, `/api/franchise-leads`.

---

## 3. Environment Variables

List of required environment variable names (No secret values printed):

- `MONGO_URI` — required (Primary MongoDB connection URI)
- `MONGODB_URI` — optional fallback (Local/Secondary MongoDB connection URI)
- `NODE_ENV` — optional (`development` / `production`)
- `PORT` — optional (Backend server port, default `5000`)
- `FRONTEND_URL` — optional (CORS allowed origin URL)
- `FRONTEND_URLS` — optional (Comma-separated CORS allowed origin URLs)
- `EMAIL_USER` — required for email service (SMTP email address)
- `EMAIL_PASS` — required for email service (SMTP app password)
- `ADMIN_EMAIL` — required (Admin login email)
- `ADMIN_PASSWORD` — required / optional if hash used (Admin login password)
- `ADMIN_PASSWORD_HASH` — optional (Hashed admin password)
- `JWT_SECRET` — required (Secret key for signing JWT tokens)
- `JWT_EXPIRES_IN` — optional (Token expiration duration, default `2h`)
- `PAYMENT_PROVIDER` — optional placeholder (`razorpay` / `payu` / `phonepe` / `stripe`)
- `PAYMENT_PROVIDER_KEY` — optional placeholder
- `PAYMENT_PROVIDER_SECRET` — optional placeholder
- `PAYMENT_WEBHOOK_SECRET` — optional placeholder

---

## 4. MongoDB

Provider:
MongoDB Atlas (Cloud) / Local MongoDB

Connection type:
Mongoose (`mongoose.connect` v8.3.1 with DNS custom servers `8.8.8.8`, `1.1.1.1` and `family: 4`)

Environment Variable Used:
`MONGO_URI` (or fallback `MONGODB_URI`)

Database Safety Note:
No database connection, migration, schema change, or data manipulation was executed during this audit.

---

## 5. Website Hosting

Provider:
NOT IDENTIFIED (Evidence of Vercel test deployments found in `server.js` CORS allowed origins `mrwashwala-hwgn.vercel.app` & `mkariappak-debug-mrwashwala.vercel.app`, and Netlify build configuration in `netlify.toml`, but no active canonical production website hosting is currently configured).

Domain:
NOT IDENTIFIED

---

## 6. Backend Hosting

Provider:
NOT IDENTIFIED

Production API:
NOT AVAILABLE (Backend is currently run only in local development environments at `http://localhost:5000` / `http://10.0.2.2:5000`).

---

## 7. Domain

NOT IDENTIFIED (Domain names `mrwashwala.com` and `www.mrwashwala.com` appear only as configuration placeholders in `.env.example`).

---

## 8. CORS

Configuration Summary:
- Implemented dynamically using the `cors` package in `server/server.js`.
- Whitelists origins from `process.env.FRONTEND_URL` and `process.env.FRONTEND_URLS` (comma-separated).
- In non-production (`NODE_ENV !== 'production'`), permits `http://localhost:5173`, `http://localhost:5174`, `https://mrwashwala-hwgn.vercel.app`, and `https://mkariappak-debug-mrwashwala.vercel.app`.
- Requests with no `Origin` header (such as native Flutter mobile apps and curl/Postman tools) are explicitly allowed.

---

## 9. Payment

Provider:
PENDING_PROVIDER_SETUP (Adapter pattern in `server/services/payments/providerAdapter.js`)

Production readiness:
NOT READY (Architecture for checkout initiate, callback verification, and webhook processing is implemented, but active provider integration credentials like Razorpay/PhonePe are pending configuration).

---

## 10. Email / WhatsApp

Dependencies:
- **Email Service**: Dependent on SMTP via `nodemailer` configured for Gmail (`smtp.gmail.com`, port 587) in `server/routes/FranchiseLeadRoutes.js`. Requires `EMAIL_USER` and `EMAIL_PASS`. Used for notifying admins when a user requests a franchise brochure.
- **WhatsApp Service**: NOT INTEGRATED / NO DEPENDENCY.

---

## 11. File Storage

Dependencies:
- File Storage: No cloud object storage dependency (such as AWS S3 or Cloudinary).
- Static File Serving: Express serves the compiled React web app from `client/dist`.

---

## 12. Admin Dashboard

Current API Dependency:
- Located in `client/src/`.
- Configured via `VITE_API_URL` environment variable in `client/src/api/api.js`.
- In development mode, defaults to `http://localhost:5000`. In production, defaults to `VITE_API_URL` or relative path `/`.

---

## 13. Production Requirements

The following items are missing before production launch:
1. **Cloud Hosting for Backend**: Production server environment (e.g. Render, Railway, AWS, DigitalOcean) with SSL (HTTPS).
2. **Production MongoDB Atlas Cluster**: Dedicated cloud database cluster with production connection string.
3. **Domain Name & DNS**: Registered domain (e.g. `mrwashwala.com` & `api.mrwashwala.com`) with SSL certificates.
4. **Production Environment Secrets**: Live `.env` configuration for JWT secret, admin credentials, and email credentials on cloud backend.
5. **Payment Gateway Credentials**: Real credentials for Razorpay, PhonePe, or selected payment gateway.
6. **Firebase Push Notifications (FCM)**: `google-services.json` and server keys for mobile push notifications.

---

## 14. Current Architecture

```text
CURRENT (DEVELOPMENT):

React Web / Admin
   ↓ (http://localhost:5173 -> http://localhost:5000)
Express Backend (Local Port 5000)
   ↓ (MONGO_URI)
MongoDB (Local / Atlas Cluster)

Flutter Mobile App
   ↓ (http://10.0.2.2:5000 / LAN IP)
Express Backend (Local Port 5000)
   ↓ (MONGO_URI)
MongoDB (Local / Atlas Cluster)
```

```text
TARGET (PRODUCTION):

React Web / Admin
   ↓ (HTTPS)
Production Cloud Backend (Render / Railway / AWS / DigitalOcean)
   ↓ (TLS Connection)
Production MongoDB Atlas

Flutter Mobile App
   ↓ (HTTPS)
Production Cloud Backend (Render / Railway / AWS / DigitalOcean)
   ↓ (TLS Connection)
Production MongoDB Atlas
```

---

## 15. Recommended Hosting Options

The existing Node.js / Express backend + React frontend architecture supports multiple modern cloud hosting options:

1. **Render (Render.com)**
   - Web Service for Express backend (`npm start`)
   - Static Site / Web Service for React frontend
   - Native free/paid SSL certificates and environment variable management

2. **Railway (Railway.app)**
   - Simple GitHub integration for Node.js backend
   - Managed environment variables and custom domain SSL mapping

3. **AWS (Amazon Web Services)**
   - AWS App Runner / Elastic Beanstalk or EC2 + S3 / CloudFront
   - Enterprise scalability and control

4. **DigitalOcean (App Platform / Droplet)**
   - App Platform for Node.js app containerized/managed hosting or VPS Droplet with Nginx + PM2

*Note: Hosting provider selection will be finalized in subsequent stages after evaluating cost, scalability, and deployment complexity.*

---

## 16. Changes Made

NO APPLICATION CHANGES

---

## 17. Final Status

DISCOVERY COMPLETE
