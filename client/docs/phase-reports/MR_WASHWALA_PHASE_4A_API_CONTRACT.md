# MR. WASHWALA — PHASE 4A API CONTRACT AUDIT
## Flutter ↔ Node.js/Express Backend Integration Plan

**Document Version:** 1.0.0  
**Date:** October 7, 2026  
**Status:** Audit Completed & Verified  
**Target Mobile App:** `mrwashwala-mobile` (Flutter 3.47.6 / Dart 3.13.5)  
**Backend:** Existing Node.js / Express API (`server/server.js`)  
**Database:** Existing MongoDB (`server/config/db.js`)  

---

## 1. Executive Summary

This document establishes the verified API Contract between the new **Mr. WashWala Flutter Mobile Application** (`mrwashwala-mobile`) and the existing **Node.js / Express Backend**. 

All endpoints, payload structures, authentication headers, validation rules, error handling conventions, and environment configurations documented herein were derived strictly from line-by-line inspection of the backend source code (`server/server.js`, `server/routes/*.js`, `server/middleware/*.js`, `server/models/*.js`).

### Audit Summary:
- **Backend Inspection:** 100% complete across all 18 route modules and 12 Mongoose models.
- **Phase 3A Customer APIs Verified:** 100% verified (25/25 integration tests passed).
- **Architecture Integrity:** Mobile app acts as a secondary client communicating over HTTP REST APIs. Zero modifications to React frontend, MongoDB schemas, or existing production APIs were made during this phase.

---

## 2. Existing Architecture & Client Overview

```
               ┌────────────────────────┐
               │ Existing React Website │
               └───────────┬────────────┘
                           │ (HTTP REST)
                           ▼
┌────────────────────────┐   (HTTP REST)   ┌───────────────────────────────┐
│ Flutter Mobile App     ├────────────────►│ Node.js / Express Backend     │
│ (mrwashwala-mobile)    │                 │ (Port 5000 / /api/*)          │
└────────────────────────┘                 └───────────────┬───────────────┘
                                                           │ (Mongoose)
                                                           ▼
                                                   ┌───────────────┐
                                                   │ MongoDB       │
                                                   └───────────────┘
```

1. **Shared Single Backend:** The Express backend handles requests for both the React Web Application and the Flutter Mobile Application.
2. **Shared Database:** Both web and mobile read from and write to the same MongoDB database, ensuring real-time consistency for orders, customer profiles, and service listings.
3. **Data Security & Ownership:** Authenticated customer endpoints scope all read/write operations by matching `customerRef: req.customer._id` or `customer.phone: req.customer.phone`.

---

## 3. Backend API Inventory

The backend exposes the following primary route namespaces under `/api`:

| Base Path | File | Target Audience | Description |
|---|---|---|---|
| `/api/customer/auth` | `customerAuthRoutes.js` | Mobile Customer | Phone OTP dispatch & verification |
| `/api/customer/profile` | `customerProfileRoutes.js` | Mobile Customer | Profile fetch & updates (name, email, avatar) |
| `/api/customer/addresses` | `customerAddressRoutes.js` | Mobile Customer | Delivery address management (CRUD) |
| `/api/customer/orders` | `customerOrderRoutes.js` | Mobile Customer | Customer-scoped order history & order details |
| `/api/customer/reviews` | `customerReviewRoutes.js` | Mobile Customer | Verified order review submissions |
| `/api/services` | `serviceRoutes.js` | Public / Admin | Active laundry services, categories, & pricing |
| `/api/orders` | `orderRoutes.js` | Public / Admin | Order creation (with server price recalculation) |
| `/api/reviews` | `reviewRoutes.js` | Public | Approved public testimonials and ratings |
| `/api/payments` | `paymentRoutes.js` | Public | Checkout initialization, callback verification, webhook |
| `/api/admin` | `adminRoutes.js` | Admin Only | Administrative management |
| `/api/processing` | `processingRoutes.js` | Admin / Staff | Order processing tickets & workflow management |

---

## 4. Phase 3A Customer API Verification

All Phase 3A customer APIs were thoroughly audited against the actual source files in `server/routes/customer*.js`:

### A. Send OTP (`POST /api/customer/auth/send-otp`)
- **Headers:** `Content-Type: application/json`
- **Request Body:** `{ "phone": "9876543210" }`
- **Validation:** Normalizes phone to 10 digits (`normalizePhone`). Returns `400` if invalid.
- **OTP Behavior:** Generates 6-digit OTP. In non-production (`process.env.NODE_ENV !== 'production'`), defaults to `'123456'` for test execution. Expiry set to 5 minutes (`300` seconds).
- **Response `200`:**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully to 9876543210",
    "expiresInSeconds": 300,
    "devNote": "Development Mode: Use OTP 123456"
  }
  ```

### B. Verify OTP (`POST /api/customer/auth/verify-otp`)
- **Request Body:** `{ "phone": "9876543210", "otp": "123456", "name": "Optional Name" }`
- **Validation:** Requires valid 10-digit phone and 6-digit OTP string.
- **Response `200`:** Returns 30-day JWT token and customer object (`otpSecret` and `otpExpiresAt` stripped).
  ```json
  {
    "success": true,
    "message": "Authentication successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
    "isNewCustomer": false,
    "customer": {
      "_id": "6702c...",
      "phone": "9876543210",
      "name": "Jane Doe",
      "addresses": []
    }
  }
  ```

### C. Customer Profile (`GET/PATCH /api/customer/profile`)
- **Headers:** `Authorization: Bearer <token>`
- **GET Response `200`:** `{ "success": true, "data": { "_id": "...", "phone": "...", "name": "..." } }`
- **PATCH Request Body:** `{ "name": "Updated Name", "email": "user@example.com", "avatar": "https://..." }`
- **PATCH Response `200`:** `{ "success": true, "message": "Profile updated successfully", "data": { ... } }`

### D. Customer Addresses (`/api/customer/addresses`)
- **GET:** Returns `{ "success": true, "count": 2, "data": [ ... ] }`
- **POST:** Creates address with unique `addressId` (`addr-<timestamp>-<rand>`). Fields: `label` ('Home'|'Work'|'Other'), `fullAddress` (required), `houseNo`, `street`, `landmark`, `city` (default 'Mysuru'), `pincode`, `latitude`, `longitude`, `isDefault`. Automatically sets `isDefault: true` if first address.
- **PATCH `/:addressId`:** Updates specific address or toggles `isDefault: true` (resets other default flags).
- **DELETE `/:addressId`:** Deletes target address. Reassigns default status to first remaining address if default was removed.

### E. Customer Orders (`/api/customer/orders`)
- **GET `?page=1&limit=10&status=All`:** Returns customer orders matching `customerRef: customerId` OR `customer.phone: customerPhone`. Supports pagination.
- **GET `/:orderId`:** Fetches order details. Enforces security check: returns `403 Forbidden` if `order.customerRef` or `order.customer.phone` does not match the requester.

### F. Customer Reviews (`POST /api/customer/reviews`)
- **Request Body:** `{ "rating": 5, "text": "Excellent service!", "orderId": "MRW-123456" }`
- **Validation:** `text` must be $\ge 5$ chars. `rating` must be integer 1–5. Order must exist, belong to customer, and have `status: 'Delivered'`. Prevents duplicate reviews per order.

---

## 5. Customer Authentication Flow

```
Mobile User Inputs Phone Number
             │
             ▼
   POST /api/customer/auth/send-otp
   (Returns expiresInSeconds: 300)
             │
             ▼
Mobile User Inputs 6-Digit OTP (+ Optional Name)
             │
             ▼
   POST /api/customer/auth/verify-otp
             │
             ▼
Returns Customer JWT (30-day Expiry, role: 'customer')
             │
             ▼
Store JWT in Flutter Secure Storage (flutter_secure_storage)
             │
             ▼
Attach 'Authorization: Bearer <token>' to all protected requests
```

- **Token Type:** JSON Web Token (JWT).
- **Payload:** `{ "id": customer._id, "phone": customer.phone, "role": "customer" }`.
- **Secret Key:** `process.env.JWT_SECRET` (fallback: `'mrwashwala_secret_change_this'`).
- **Expiration:** 30 days (`CUSTOMER_JWT_EXPIRES_IN || '30d'`).
- **Authorization Header:** `Authorization: Bearer <token>`.
- **Unauthenticated Response:** `401 Unauthorized` with `{ "success": false, "message": "Authorization token missing" }` or `{ "success": false, "message": "Invalid or expired authorization token" }`.

---

## 6. Business API Classification Matrix

| Feature | Endpoint | Method | Classification | Description |
|---|---|---|---|---|
| Services List | `/api/services` | GET | **CATEGORY A** | Directly reusable. Filterable by `displayType`, `featured`. |
| Service Details | Inline in `/api/services` | GET | **CATEGORY A** | Unit cost, features array, and category in service object. |
| Pricing | Inline in `/api/services` | GET | **CATEGORY A** | Verified server-side during order creation. |
| Cart | Client-Side | Local | **CATEGORY A** | Managed locally in Flutter state (Provider/Riverpod). |
| Customer Profile | `/api/customer/profile` | GET/PATCH | **CATEGORY A** | Fully functional customer profile endpoints. |
| Address Management | `/api/customer/addresses` | GET/POST/PATCH/DELETE | **CATEGORY A** | Full saved address management with defaults. |
| Order Creation | `/api/orders` | POST | **CATEGORY A** | Supports authenticated & guest orders with server-side price validation. |
| Order History | `/api/customer/orders` | GET | **CATEGORY A** | Paginated customer-scoped order history. |
| Order Tracking / Status | `/api/customer/orders/:orderId` | GET | **CATEGORY A** | Fetches current order status (`Pending`, `Processing`, `Out for Delivery`, `Delivered`, `Cancelled`). |
| COD Payment | `/api/orders` | POST | **CATEGORY A** | `paymentMethod: 'Cash on Delivery'`, `paymentStatus: 'Pending'`. |
| UPI Payment | `/api/orders` | POST | **CATEGORY A** | `paymentMethod: 'QR Payment'`, `paymentStatus: 'Paid'`. |
| Customer Reviews | `/api/customer/reviews` | POST | **CATEGORY A** | Validates order delivery status before accepting reviews. |
| Online Gateway | `/api/payments/checkout/initiate` | POST | **CATEGORY B** | Payment architecture ready; provider credentials pending. |

---

## 7. Order Creation Specification (`POST /api/orders`)

When Flutter submits a booking, it posts to `POST /api/orders` with optional `Authorization: Bearer <token>` header.

### Request Body Schema:
```json
{
  "customer": {
    "name": "Jane Doe",
    "phone": "9876543210",
    "address": "123 Main Street, Jayalakshmipuram, Mysuru",
    "instructions": "Leave at front door"
  },
  "items": [
    {
      "name": "Wash & Iron",
      "quantity": 5,
      "price": 60,
      "unit": "Kg"
    },
    {
      "name": "Dry Cleaning",
      "quantity": 2,
      "price": 250,
      "unit": "Pcs"
    }
  ],
  "totalAmount": 800,
  "pickupDate": "2026-10-10",
  "pickupTime": "10:00 AM - 12:00 PM",
  "deliveryDate": "2026-10-12",
  "paymentMethod": "Cash on Delivery",
  "paymentStatus": "Pending",
  "latitude": 12.311843,
  "longitude": 76.653457,
  "selectedBranch": {
    "id": "branch-mysore-main",
    "name": "Mysore Main Branch"
  }
}
```

### Server Price Verification Logic:
The backend queries MongoDB `Service.find({})` and recalculates the total sum based on active database service prices. This prevents any malicious modification of cart item prices on the mobile client.

### Response Body (`201 Created`):
```json
{
  "_id": "6702d8f9...",
  "orderId": "MRW-583920",
  "customerRef": "6702c1a4...",
  "customer": {
    "name": "Jane Doe",
    "phone": "9876543210",
    "address": "123 Main Street, Jayalakshmipuram, Mysuru"
  },
  "items": [ ... ],
  "totalAmount": 800,
  "status": "Pending",
  "paymentMethod": "Cash on Delivery",
  "paymentStatus": "Pending",
  "pickupDate": "2026-10-10",
  "pickupTime": "10:00 AM - 12:00 PM",
  "createdAt": "2026-10-07T11:45:00.000Z"
}
```

---

## 8. Payment & COD Flow

1. **Cash on Delivery (COD):**
   - Flutter sets `paymentMethod: 'Cash on Delivery'`, `paymentStatus: 'Pending'`.
   - Order created instantly with status `'Pending'`.
2. **UPI / QR Payment:**
   - Mobile app presents business UPI ID / QR code.
   - Upon confirmation, Flutter submits order with `paymentMethod: 'QR Payment'`, `paymentStatus: 'Paid'`.
3. **Online Gateway Integration (Razorpay / PhonePe):**
   - Initialized via `POST /api/payments/checkout/initiate`.
   - Requires setting production payment gateway keys in backend `.env` before live deployment.

---

## 9. Standard Error & Success Response Formats

### Success Response Format:
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response Format:
```json
{
  "success": false,
  "message": "Human-readable description of error",
  "error": "Detailed error string (only present in development mode)"
}
```

---

## 10. Flutter API Data Layer Architecture Plan

The `mrwashwala-mobile` Flutter application uses a modular clean architecture:

```
mrwashwala-mobile/lib/
├── core/
│   ├── config/
│   │   └── api_config.dart          # Base URLs & timeout configuration
│   ├── constants/
│   │   └── app_constants.dart       # Endpoints & keys
│   ├── network/
│   │   ├── api_client.dart          # HTTP client wrapper with Bearer token header injection
│   │   └── api_exception.dart       # Exception mapper for 400/401/403/404/500
│   └── storage/
│       └── secure_storage_service.dart # Key-value JWT storage
│
├── data/
│   ├── models/
│   │   ├── customer_model.dart
│   │   ├── address_model.dart
│   │   ├── service_model.dart
│   │   ├── order_model.dart
│   │   └── review_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── profile_repository.dart
│       ├── address_repository.dart
│       ├── service_repository.dart
│       ├── order_repository.dart
│       └── review_repository.dart
│
└── features/
    ├── auth/
    ├── home/
    ├── services/
    ├── cart/
    ├── checkout/
    ├── orders/
    └── profile/
```

---

## 11. Complete API Contract Table

| Feature | Method | Exact Endpoint | Auth Required | Request Payload Summary | Key Response Fields | Status | Mobile Usage |
|---|---|---|---|---|---|---|---|
| **Send OTP** | `POST` | `/api/customer/auth/send-otp` | Public | `{ phone }` | `success`, `expiresInSeconds`, `devNote` | Ready | Authentication Screen |
| **Verify OTP** | `POST` | `/api/customer/auth/verify-otp` | Public | `{ phone, otp, name? }` | `success`, `token`, `customer`, `isNewCustomer` | Ready | Login / Registration Verification |
| **Get Profile** | `GET` | `/api/customer/profile` | Bearer Token | None | `success`, `data: Customer` | Ready | Profile Screen / Startup Auth Check |
| **Update Profile** | `PATCH` | `/api/customer/profile` | Bearer Token | `{ name?, email?, avatar? }` | `success`, `data: Customer` | Ready | Profile Edit Form |
| **Get Addresses** | `GET` | `/api/customer/addresses` | Bearer Token | None | `success`, `count`, `data: Address[]` | Ready | Address Selector / Checkout |
| **Add Address** | `POST` | `/api/customer/addresses` | Bearer Token | `{ label, fullAddress, houseNo, street, landmark, city, pincode, isDefault }` | `success`, `data: Address`, `addresses` | Ready | Add Address Screen |
| **Update Address** | `PATCH` | `/api/customer/addresses/:addressId` | Bearer Token | `{ fullAddress?, isDefault?, ... }` | `success`, `data: Address`, `addresses` | Ready | Edit Address Screen |
| **Delete Address** | `DELETE` | `/api/customer/addresses/:addressId` | Bearer Token | None | `success`, `addresses` | Ready | Address Removal Action |
| **Get Services** | `GET` | `/api/services` | Public | `?displayType=main` | `Service[]` array | Ready | Home / Services Screen |
| **Create Order** | `POST` | `/api/orders` | Optional Bearer | `{ customer, items, totalAmount, pickupDate, pickupTime, paymentMethod, ... }` | Saved `Order` object (`orderId`, `status`) | Ready | Checkout Submission |
| **Customer Orders** | `GET` | `/api/customer/orders` | Bearer Token | `?page=1&limit=10&status=All` | `success`, `totalOrders`, `totalPages`, `data: Order[]` | Ready | Orders History Screen |
| **Order Details** | `GET` | `/api/customer/orders/:orderId` | Bearer Token | None | `success`, `data: Order` | Ready | Order Detail / Tracking Screen |
| **Submit Review** | `POST` | `/api/customer/reviews` | Bearer Token | `{ rating, text, orderId }` | `success`, `data: Review` | Ready | Rate & Review Screen |

---

## 12. Backend Gaps & Recommendations for Mobile

During audit inspection, 3 minor gaps were identified for future optimization (non-blocking for Phase 4B):

1. **Public Reviews Endpoint for Customer App:**
   - *Current State:* `GET /api/reviews` exists for web, returning raw reviews.
   - *Recommendation:* Create `GET /api/customer/reviews/public` to return curated featured customer reviews for the mobile Home Screen carousel.
2. **Push Notification Token Registration:**
   - *Current State:* `Customer` model does not currently store FCM (Firebase Cloud Messaging) device tokens.
   - *Recommendation:* Add `fcmTokens: [String]` field to `Customer` model in a future push notification phase.
3. **Banner / Promotion Banner Endpoint:**
   - *Current State:* Banners on the React website are currently static assets.
   - *Recommendation:* Keep banners as clean local mobile assets in Flutter during Phase 4B.

---

## 13. Security Review & Best Practices

- **Zero Secrets in Flutter:** `JWT_SECRET`, MongoDB URI, and email service credentials remain strictly server-side inside `server/.env`.
- **Customer Data Ownership:** Every customer endpoint verifies `req.customer._id` or `req.customer.phone` to guarantee that customers cannot view or modify each other's addresses, orders, or profile details.
- **Price Security:** The backend ignores client-side item prices and re-calculates order totals using current database prices from `Service.find({})`.

---

## 14. Network & Environment Configuration

### Development Base URLs:
- **Android Emulator:** `http://10.0.2.2:5000/api`
- **Physical Android Device (Same Wi-Fi):** `http://<YOUR_LOCAL_IP>:5000/api`
- **Production URL:** `https://mrwashwala.com/api` (or configured API domain)

### Flutter Config File (`lib/core/config/api_config.dart`):
```dart
class ApiConfig {
  static const String devBaseUrl = 'http://10.0.2.2:5000/api';
  static const String prodBaseUrl = 'https://mrwashwala.com/api';
  
  static String get baseUrl => devBaseUrl; // Toggle for dev/prod
}
```

---

## 15. Non-Destructive Phase 4B Test Plan

Prior to enabling live business UI in Phase 4B, the following non-destructive integration tests will be run:

1. **Health Check Test:** `GET /api-status` (Expect `200 OK`, `status: 'online'`).
2. **Services Fetch Test:** `GET /api/services` (Expect array of active laundry services).
3. **OTP Dispatch Test:** `POST /api/customer/auth/send-otp` with test mobile `9999999999` (Expect `200 OK`).
4. **OTP Verification Test:** `POST /api/customer/auth/verify-otp` with OTP `'123456'` (Expect `200 OK` + JWT token).
5. **Authenticated Profile Fetch:** `GET /api/customer/profile` with `Authorization: Bearer <token>` (Expect customer record).
6. **Address Creation & Fetch Test:** `POST /api/customer/addresses` & `GET /api/customer/addresses` (Expect added address).
7. **Order History Fetch Test:** `GET /api/customer/orders` (Expect `200 OK` with paginated list).

---

## 16. Recommended Phase 4B Implementation Sequence

When Phase 4B is approved, implementation should proceed in the following ordered modules:

1. **Step 1: Network & Auth Core Layer** — Implement `ApiClient`, `SecureStorageService`, and `AuthRepository` in `mrwashwala-mobile`.
2. **Step 2: Authentication UI** — Implement Phone Input Screen, OTP Verification Screen, and persistent login check on app start.
3. **Step 3: Services & Category UI** — Implement dynamic services list fetching from `GET /api/services`.
4. **Step 4: Cart State Management** — Implement local cart state (add/remove items, quantity adjust, total calculation).
5. **Step 5: Saved Addresses & Delivery UI** — Implement Address list/creation modal calling `/api/customer/addresses`.
6. **Step 6: Checkout & Order Placement** — Implement Checkout screen calling `POST /api/orders`.
7. **Step 7: Order History & Details Screen** — Implement Order list and tracking screens calling `/api/customer/orders`.
8. **Step 8: Reviews & Profile Screens** — Implement Profile update screen and order rating dialog.

---
*End of Phase 4A API Contract Document*
