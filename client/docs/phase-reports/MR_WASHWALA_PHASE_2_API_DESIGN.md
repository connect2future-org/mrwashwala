# MR. WASHWALA — PHASE 2: API DESIGN & BACKEND BLUEPRINT

**Project:** Mr. WashWala Laundry Booking System  
**Date:** October 6, 2026  
**Document Status:** Complete (Phase 2 — Design & Specification Blueprint)  

---

## 1. Executive Summary & Phase 2 Objectives

This document establishes the official **API Design & Backend Architecture Blueprint** for the upcoming **Mr. WashWala Customer Mobile Application (Flutter)**. 

Building upon the Phase 1 audit findings ([`MR_WASHWALA_PHASE_1_API_RESEARCH.md`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/MR_WASHWALA_PHASE_1_API_RESEARCH.md)), this phase defines the customer identity model, mobile authentication flows, secured profile & address management endpoints, customer order history querying, server-side order price validation, payment workflow integration, and customer review submission.

### Core Architectural Principles:
1. **Zero Disruption to Existing Web App:** The existing React web application and admin dashboard will continue to operate without breaking changes. Guest web checkouts remain supported.
2. **Mobile-First Customer Identity:** Introduces a dedicated `Customer` model and Customer JWT authentication (`customerAuth` middleware) completely decoupled from the existing single-admin web login.
3. **Server-Side Price Calculation Integrity:** The backend will **never trust item prices or order totals sent by the mobile app**. All order totals will be recalculated and validated server-side against live MongoDB `Service` prices.
4. **Strict Customer Data Isolation:** Mobile customers can only access, view, or update their own profile, addresses, and order history.
5. **No Source Code Changes in Phase 2:** All designs, schemas, routes, and specifications in this document are approved-ready specifications. No code or database changes were applied during this phase.

---

## 2. Review & Classification of Backend APIs

Every backend API in the Mr. WashWala system has been evaluated and classified for Flutter mobile app integration:

| Classification | Category Description | Included API Endpoints |
| :--- | :--- | :--- |
| **A. EXISTING — Directly Reusable** | Backend APIs that Flutter can use immediately without modification. | • `GET /api/services` (Fetch active services & pricing)<br>• `GET /api/reviews` (Fetch approved 5-star customer reviews)<br>• `POST /api/franchise-leads` (Submit franchise inquiries)<br>• `GET /api/payments/:merchantOrderId/status` (Poll payment status) |
| **B. EXISTING — Requires Modification** | Backend APIs requiring minor adjustments before mobile deployment. | • `POST /api/orders` (Add `Service` import, validate prices server-side, attach optional `customerId`) |
| **C. NEW — To Be Created** | Customer endpoints to be created in Phase 3. | • `POST /api/customer/auth/send-otp`<br>• `POST /api/customer/auth/verify-otp`<br>• `GET /api/customer/profile`<br>• `PATCH /api/customer/profile`<br>• `GET /api/customer/addresses`<br>• `POST /api/customer/addresses`<br>• `PATCH /api/customer/addresses/:addressId`<br>• `DELETE /api/customer/addresses/:addressId`<br>• `GET /api/customer/orders`<br>• `GET /api/customer/orders/:orderId`<br>• `POST /api/customer/reviews` |
| **D. ADMIN ONLY — Forbidden for Flutter** | Protected routes restricted exclusively to Mr. WashWala admin staff. | • `/api/auth/login`<br>• `/api/admin/*`<br>• `/api/inventory/*`<br>• `/api/expenses/*`<br>• `/api/revenue/*`<br>• `/api/analytics/*`<br>• `/api/processing/*`<br>• `/api/walkin-orders/*` |
| **E. NOT REQUIRED** | Deprecated or unnecessary endpoints for the customer app. | • `GET /debug-services`<br>• `GET /api/test` |

---

## 3. Customer Account System Architecture

To support mobile authentication and personalized features, a new Mongoose schema (`Customer.js`) is designed for implementation in `server/models/Customer.js`.

### Proposed Mongoose Schema Design (`Customer.js`):
```javascript
import mongoose from 'mongoose';

const addressSchema = new mongoose.Schema(
  {
    addressId: { type: String, required: true },
    label: { type: String, enum: ['Home', 'Work', 'Other'], default: 'Home' },
    fullAddress: { type: String, required: true, trim: true },
    houseNo: { type: String, trim: true, default: '' },
    street: { type: String, trim: true, default: '' },
    landmark: { type: String, trim: true, default: '' },
    city: { type: String, trim: true, default: 'Mysuru' },
    pincode: { type: String, trim: true, default: '' },
    latitude: { type: Number, default: null },
    longitude: { type: Number, default: null },
    isDefault: { type: Boolean, default: false }
  },
  { _id: false }
);

const customerSchema = new mongoose.Schema(
  {
    name: { type: String, trim: true, default: '' },
    phone: { type: String, required: true, unique: true, trim: true },
    email: { type: String, lowercase: true, trim: true, default: '' },
    avatar: { type: String, default: null },
    otpSecret: { type: String, select: false },
    otpExpiresAt: { type: Date, select: false },
    addresses: [addressSchema],
    isActive: { type: Boolean, default: true },
    lastLoginAt: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

const Customer = mongoose.model('Customer', customerSchema);
export default Customer;
```

### Schema Rules & Constraints:
- **Required Fields:** `phone` (10-digit mobile number, unique index).
- **Optional Fields:** `name`, `email`, `avatar`, `addresses`.
- **Security Constraint:** `otpSecret` and `otpExpiresAt` are flagged with `select: false` so OTP verification credentials are **never returned to Flutter in API responses**.
- **Customer to Order Linking:** Orders created by a logged-in mobile user will store the customer's MongoDB `_id` in a new optional field `customerRef` on the `Order` document, while maintaining existing string fields (`customer.name`, `customer.phone`, `customer.address`) for backward compatibility with admin dashboard features.

---

## 4. Customer Registration & Login Specification

### Recommended Auth Flow: Mobile Number + 6-Digit OTP
Given that laundry pickup and delivery requires a verified mobile number, **Mobile + OTP** is the optimal authentication mechanism for Mr. WashWala.

```
Flutter App                      Node.js Backend                 SMS Gateway / Mock
    │                                  │                                │
    │ 1. POST /send-otp (phone)        │                                │
    ├─────────────────────────────────►│ 2. Generate 6-Digit OTP        │
    │                                  ├───────────────────────────────►│ Send SMS
    │                                  │                                │
    │ 3. POST /verify-otp (phone, otp) │                                │
    ├─────────────────────────────────►│ 4. Verify OTP & Expiry        │
    │                                  │    (Find or Auto-Create)       │
    │ 5. Return Customer JWT Token     │                                │
    │◄─────────────────────────────────┤                                │
```

### Endpoint 1: Send OTP
- **Route:** `POST /api/customer/auth/send-otp`
- **Access:** Public (Unauthenticated)
- **Request Payload:**
  ```json
  {
    "phone": "9876543210"
  }
  ```
- **Validation:** Must be a valid 10-digit numeric string (`/^\d{10}$/`).
- **Server Business Logic:**
  1. Validates phone number.
  2. Generates a random 6-digit OTP (e.g., `582910`).
  3. Saves hashed OTP and expiration (5 minutes) in customer record (or temp store).
  4. Dispatches OTP via SMS Provider. *(Development Mode: Static OTP `123456` or logged to server console if SMS provider is unconfigured).*
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "OTP sent successfully to 9876543210",
    "expiresInSeconds": 300
  }
  ```
- **Error Response (400 Bad Request):**
  ```json
  {
    "success": false,
    "message": "Please enter a valid 10-digit mobile number"
  }
  ```

### Endpoint 2: Verify OTP & Issue Token
- **Route:** `POST /api/customer/auth/verify-otp`
- **Access:** Public (Unauthenticated)
- **Request Payload:**
  ```json
  {
    "phone": "9876543210",
    "otp": "582910",
    "name": "Ajay Kumar"
  }
  ```
- **Server Business Logic:**
  1. Validates phone and OTP inputs.
  2. Checks OTP match and verifies it has not expired (`now < otpExpiresAt`).
  3. Finds existing `Customer` by phone or automatically registers a new `Customer`.
  4. Updates `lastLoginAt` timestamp.
  5. Signs a Customer JWT Token using `jsonwebtoken`.
- **Success Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Authentication successful",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "isNewCustomer": false,
    "customer": {
      "_id": "66f1a8b9c2e01123456789ab",
      "name": "Ajay Kumar",
      "phone": "9876543210",
      "email": "ajay@example.com",
      "avatar": null,
      "addresses": []
    }
  }
  ```
- **Error Response (401 Unauthorized):**
  ```json
  {
    "success": false,
    "message": "Invalid or expired OTP. Please request a new one."
  }
  ```

---

## 5. Authentication Middleware (`customerAuth`)

To protect customer endpoints, a dedicated middleware `customerAuth` will be implemented in `server/middleware/customerAuthMiddleware.js`.

### Authentication Specification:
- **Token Type:** JSON Web Token (JWT) using `Bearer` header scheme.
- **Header Format:** `Authorization: Bearer <customer_jwt_token>`
- **Token Payload Structure:**
  ```json
  {
    "id": "66f1a8b9c2e01123456789ab",
    "phone": "9876543210",
    "role": "customer",
    "iat": 1759760000,
    "exp": 1762352000
  }
  ```
- **Token Expiration:** 30 Days (Mobile apps require long-lived sessions to prevent frequent re-logins).

### Middleware Execution Logic:
1. Extracts `Authorization` header from HTTP request.
2. Verifies header starts with `Bearer `.
3. Decodes token using `process.env.JWT_SECRET`.
4. Checks `decoded.role === 'customer'`. If `decoded.role === 'admin'`, rejects with `403 Forbidden` to enforce role separation.
5. Queries `Customer.findById(decoded.id)`. If customer is missing or `isActive === false`, returns `401 Unauthorized`.
6. Attaches customer document to request object (`req.customer = customerDoc`) and invokes `next()`.

---

## 6. Customer Profile APIs

### 1. Get Customer Profile
- **Route:** `GET /api/customer/profile`
- **Access:** Customer (`customerAuth` required)
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "data": {
      "_id": "66f1a8b9c2e01123456789ab",
      "name": "Ajay Kumar",
      "phone": "9876543210",
      "email": "ajay@example.com",
      "avatar": null,
      "addresses": [
        {
          "addressId": "addr-101",
          "label": "Home",
          "fullAddress": "House #42, 2nd Main, Vijayanagar 2nd Stage, Mysuru",
          "city": "Mysuru",
          "pincode": "570017",
          "isDefault": true
        }
      ],
      "createdAt": "2026-10-06T14:11:28.000Z"
    }
  }
  ```

### 2. Update Customer Profile
- **Route:** `PATCH /api/customer/profile`
- **Access:** Customer (`customerAuth` required)
- **Editable Fields:** `name`, `email`, `avatar`.
- **Non-Editable Fields:** `_id`, `phone` (phone number updates require a separate OTP re-verification flow), `createdAt`.
- **Request Payload:**
  ```json
  {
    "name": "Ajay K.",
    "email": "ajay.k@example.com"
  }
  ```
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "message": "Profile updated successfully",
    "data": {
      "_id": "66f1a8b9c2e01123456789ab",
      "name": "Ajay K.",
      "phone": "9876543210",
      "email": "ajay.k@example.com"
    }
  }
  ```

---

## 7. Saved Address APIs

Mobile customers need to save and select delivery addresses during checkout.

### Address Schema Structure:
- `addressId`: Unique string (e.g., `addr-1759760000-a1b2`).
- `label`: `'Home'`, `'Work'`, or `'Other'`.
- `fullAddress`: Complete address string.
- `houseNo`, `street`, `landmark`, `city`, `pincode`.
- `latitude`, `longitude`: Optional coordinates for GPS distance matching.
- `isDefault`: Boolean. If set to `true`, all other addresses for this customer are automatically updated to `isDefault: false`.

### Endpoints Specification:

1. **GET `/api/customer/addresses`**
   - **Access:** Customer (`customerAuth`)
   - **Response:** Returns array of customer's saved addresses.

2. **POST `/api/customer/addresses`**
   - **Access:** Customer (`customerAuth`)
   - **Request Payload:**
     ```json
     {
       "label": "Home",
       "fullAddress": "Flat 302, Green Acres, Kuvempu Nagar, Mysuru",
       "houseNo": "Flat 302",
       "street": "Kuvempu Nagar Main Rd",
       "landmark": "Near Apollo Hospital",
       "city": "Mysuru",
       "pincode": "570023",
       "latitude": 12.2905,
       "longitude": 76.6340,
       "isDefault": true
     }
     ```
   - **Business Logic:** Generates `addressId`. If `isDefault: true`, resets previous default addresses. Appends to `customer.addresses` array and saves.

3. **PATCH `/api/customer/addresses/:addressId`**
   - **Access:** Customer (`customerAuth`)
   - **Purpose:** Updates existing address details or sets it as default.

4. **DELETE `/api/customer/addresses/:addressId`**
   - **Access:** Customer (`customerAuth`)
   - **Purpose:** Removes specified address from `customer.addresses` array.

---

## 8. Customer Order History APIs

### 1. Get Customer Orders List
- **Route:** `GET /api/customer/orders`
- **Access:** Customer (`customerAuth`)
- **Query Parameters:** `page=1`, `limit=10`, `status=Pending`
- **Database Query:**
  ```javascript
  const customerPhone = req.customer.phone;
  const customerId = req.customer._id;
  
  // Matches either customerRef OR phone number for seamless legacy order access
  const filter = {
    $or: [
      { customerRef: customerId },
      { 'customer.phone': customerPhone }
    ]
  };
  
  const orders = await Order.find(filter)
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();
  ```
- **Response (200 OK):**
  ```json
  {
    "success": true,
    "count": 1,
    "page": 1,
    "totalPages": 1,
    "data": [
      {
        "_id": "66f2b9...",
        "orderId": "MRW-482910",
        "totalAmount": 300,
        "status": "In Process",
        "paymentStatus": "Pending",
        "paymentMethod": "WhatsApp Checkout",
        "pickupDate": "2026-10-07",
        "pickupTime": "14:00",
        "itemsCount": 1,
        "selectedBranch": { "name": "Mr. WashWala - Vijayanagar 2nd Stage" },
        "createdAt": "2026-10-06T14:11:28.000Z"
      }
    ]
  }
  ```

### 2. Get Single Order Details
- **Route:** `GET /api/customer/orders/:orderId`
- **Access:** Customer (`customerAuth`)
- **Security Isolation Enforcement:**
  ```javascript
  const order = await Order.findOne({ orderId: req.params.orderId });
  if (!order) {
    return res.status(404).json({ success: false, message: "Order not found" });
  }
  
  // Security Check: Enforce that order belongs to requesting customer
  const isOwner =
    order.customerRef?.toString() === req.customer._id.toString() ||
    order.customer.phone === req.customer.phone;
    
  if (!isOwner) {
    return res.status(403).json({ success: false, message: "Forbidden: You cannot access this order" });
  }
  ```
- **Response:** Returns full `Order` document including line items, prices, status tracking, and pickup date/time.

---

## 9. Order Creation API Specification for Mobile App

The mobile application will call `POST /api/orders`. 

### Server-Side Price Recalculation & Validation Rule:
> [!CRITICAL]
> **Security Requirement:** The backend **MUST NOT TRUST** item prices or `totalAmount` submitted by the mobile app. 
> Upon receiving `items` array, the backend will fetch active services from MongoDB `Service.find({})` and recalculate every line item's price and the order total server-side:
> `serverPrice = dbService.price;`
> `lineTotal = serverPrice * item.quantity;`
> `recalculatedTotalAmount = sum(lineTotals);`

### Payload Specification for Mobile `POST /api/orders`:
```json
{
  "customer": {
    "name": "Ajay Kumar",
    "phone": "9876543210",
    "address": "Flat 302, Green Acres, Kuvempu Nagar, Mysuru",
    "instructions": "Leave at gate if unavailable"
  },
  "items": [
    {
      "name": "Wash & Fold",
      "quantity": 5,
      "unit": "Kg"
    }
  ],
  "pickupDate": "2026-10-08",
  "pickupTime": "14:00",
  "paymentMethod": "Cash on Delivery",
  "latitude": 12.2905,
  "longitude": 76.6340,
  "selectedBranch": {
    "id": "kuvempunagar-1st-stage-mysuru",
    "name": "Mr. WashWala - Kuvempu Nagar 1st Stage, Mysuru"
  }
}
```

### Backend Enhancements Required in `orderRoutes.js`:
1. Add missing import: `import Service from '../models/Service.js';`.
2. Attach `customerRef: req.customer?._id || null` if `customerAuth` middleware is present.
3. Perform server-side item price lookup and total calculation.
4. Validate pickup time window (between 10:00 AM and 8:00 PM).
5. Generate 6-digit order ID (`MRW-XXXXXX`).
6. Spawn `OrderProcessing` workflow tickets.
7. Return HTTP 201 Created with saved `Order` document.

---

## 10. Cash on Delivery (COD) Flow Specification

Cash on Delivery is the default payment flow for mobile bookings:

```
Mobile App (Flutter)                 Node.js Backend                MongoDB Atlas
    │                                       │                             │
    │ 1. Selects COD & Submits Order        │                             │
    ├──────────────────────────────────────►│ 2. Validates & Recalculates │
    │    POST /api/orders                   │    Prices Server-Side       │
    │                                       │                             │
    │                                       │ 3. Save Order (Status:      │
    │                                       │    Pending, Payment:        │
    │                                       │    Pending, Method: COD)    │
    │                                       ├────────────────────────────►│
    │ 4. HTTP 201 Created (MRW-XXXXXX)      │                             │
    │◄──────────────────────────────────────┤                             │
    │                                       │                             │
    │ 5. Display Confirmation & Real-time   │                             │
    │    Tracking Screen in Flutter         │                             │
```

### Database Initial States for COD Orders:
- `order.status` = `'Pending'`
- `order.paymentStatus` = `'Pending'`
- `order.paymentMethod` = `'Cash on Delivery'`

---

## 11. Online Payment Flow Architecture

For online payment gateway integration (Razorpay / Cashfree), the backend leverages the existing architecture in [`server/routes/paymentRoutes.js`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/routes/paymentRoutes.js):

```
Mobile App (Flutter)           Node.js Backend             Payment Gateway (Razorpay)
    │                                 │                                │
    │ 1. POST /payments/checkout/init │                                │
    ├────────────────────────────────►│ 2. Create PaymentAttempt       │
    │                                 │    & Gateway Order ID          │
    │ 3. Returns gatewayOrderId       │◄───────────────────────────────┤
    │◄────────────────────────────────┤                                │
    │                                 │                                │
    │ 4. Launch Gateway SDK & Pay     │                                │
    ├─────────────────────────────────────────────────────────────────►│
    │ 5. Payment Success Callback     │                                │
    │◄─────────────────────────────────────────────────────────────────┤
    │                                 │                                │
    │ 6. POST /payments/verify        │                                │
    ├────────────────────────────────►│ 7. Verify Signature            │
    │                                 │ 8. Set paymentStatus = 'Paid'  │
    │ 9. Order Confirmed (Paid)       │                                │
    │◄────────────────────────────────┤                                │
```

### Payment Verification & Webhook Handling:
- Client verification endpoint `POST /api/payments/verify` validates HMAC signature.
- Webhook receiver `POST /api/payments/webhook` stores raw events in `PaymentWebhookEvent` for idempotent retry processing.

---

## 12. Customer Review API Design

To allow mobile app customers to submit reviews after receiving their laundry:

- **Route:** `POST /api/customer/reviews`
- **Access:** Customer (`customerAuth` required)
- **Request Payload:**
  ```json
  {
    "orderId": "MRW-482910",
    "rating": 5,
    "text": "Excellent laundry service! Clothes came back crisp and clean."
  }
  ```
- **Validation Rules:**
  1. `rating` must be an integer between 1 and 5.
  2. `text` must not be empty (minimum 5 characters).
  3. **Order Verification:** Backend checks if `orderId` exists and has `status === 'Delivered'` to prevent fake reviews.
- **Database Action:** Creates document in `Review` collection with `approved: true`, `source: 'api'`.

---

## 13. Security & Data Isolation Specifications

| Component | Security Control | Implementation Detail |
| :--- | :--- | :--- |
| **Token Verification** | Role Isolation | `customerAuth` verifies `decoded.role === 'customer'`. Prevents customer tokens from accessing admin routes (`/api/admin/*`). |
| **Order Data Isolation** | Ownership Check | `GET /api/customer/orders/:orderId` verifies `order.customer.phone === req.customer.phone`. Customers attempting to access another user's order receive `403 Forbidden`. |
| **Profile Data Privacy** | Data Masking | Customer endpoints never expose `otpSecret` or internal auth credentials. |
| **Price Tampering Defense** | Server Recalculation | `POST /api/orders` recalculates item prices and order totals directly from database `Service` prices. |
| **Input Sanitization** | Regex & Trim | Mobile numbers, emails, and address strings are sanitized and trimmed to prevent injection attacks. |

---

## 14. Complete API Specification Table

| Method | Endpoint Path | Auth Required | Purpose & Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/customer/auth/send-otp` | Public | Sends 6-digit OTP to mobile number via SMS. |
| `POST` | `/api/customer/auth/verify-otp` | Public | Verifies OTP and returns Customer JWT token. |
| `GET` | `/api/customer/profile` | Customer JWT | Retrieves logged-in customer profile and saved addresses. |
| `PATCH` | `/api/customer/profile` | Customer JWT | Updates customer name and email address. |
| `GET` | `/api/customer/addresses` | Customer JWT | Fetches list of saved customer delivery addresses. |
| `POST` | `/api/customer/addresses` | Customer JWT | Adds a new saved delivery address. |
| `PATCH` | `/api/customer/addresses/:addressId` | Customer JWT | Updates an existing address or sets default address. |
| `DELETE` | `/api/customer/addresses/:addressId` | Customer JWT | Deletes a saved address. |
| `GET` | `/api/customer/orders` | Customer JWT | Fetches order history for logged-in customer. |
| `GET` | `/api/customer/orders/:orderId` | Customer JWT | Retrieves single order details & tracking status safely. |
| `POST` | `/api/orders` | Optional Customer JWT | Creates a new order booking (recalculates prices server-side). |
| `GET` | `/api/services` | Public | Fetches laundry services & pricing for mobile app displays. |
| `GET` | `/api/reviews` | Public | Fetches approved customer reviews for mobile homepage. |
| `POST` | `/api/customer/reviews` | Customer JWT | Submits a customer review for a delivered order. |

---

## 15. Backward Compatibility & Legacy Migration Blueprint

### Zero Web Interruption Guarantee:
1. **Existing Web Checkout:** The website checkout modal ([`CheckoutModal.jsx`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/client/src/components/CheckoutModal.jsx)) submits unauthenticated POST requests to `/api/orders`. The backend will continue to support unauthenticated guest orders.
2. **Seamless Account Linking:** When a customer registers on the Flutter mobile app using their mobile number (e.g. `9876543210`), the order query `GET /api/customer/orders` searches MongoDB by matching `customer.phone: "9876543210"`. This automatically links all past guest website bookings to their new mobile account without needing complex database migration scripts.

---

## 16. Phase 2 Completion & Verification Statement

All API designs, customer account models, mobile authentication flows, address specifications, order validation rules, and security controls for Phase 2 have been defined in full detail.

```
PHASE 2 COMPLETE — API DESIGN SPECIFIED, NO CODE MODIFIED.
```
