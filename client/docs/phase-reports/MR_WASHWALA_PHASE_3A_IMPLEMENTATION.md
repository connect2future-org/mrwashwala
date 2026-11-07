# MR. WASHWALA — PHASE 3A: BACKEND CUSTOMER API IMPLEMENTATION

**Project:** Mr. WashWala Laundry Booking System  
**Date:** October 6, 2026  
**Phase Status:** COMPLETE  

---

## 1. Executive Summary

Phase 3A successfully implements the Customer Backend Module for the Mr. WashWala Laundry Booking Platform according to the Phase 2 API Design specification ([`MR_WASHWALA_PHASE_2_API_DESIGN.md`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/MR_WASHWALA_PHASE_2_API_DESIGN.md)).

All customer authentication flows, profile management, saved address CRUD, order history, order isolation, server-side price recalculation, and customer review submissions have been built, mounted, and programmatically tested.

> [!IMPORTANT]
> **Existing Website Compatibility:** 100% preserved. Unauthenticated guest checkouts on the React website, public service listing, public review displays, and admin authentication/dashboard features continue to operate without any breaking changes.

---

## 2. Changes Implemented

### A. New Models & Schema Additions:
1. **`server/models/Customer.js`**: Created Mongoose model for customer accounts featuring 10-digit unique phone indexing, name, email, avatar, embedded addresses array (`addressId`, `label`, `fullAddress`, `houseNo`, `street`, `landmark`, `city`, `pincode`, `latitude`, `longitude`, `isDefault`), and secret fields (`otpSecret`, `otpExpiresAt`) with `select: false` security protection.
2. **`server/models/Order.js`**: Updated `orderSchema` to include an optional `customerRef` ObjectId field referencing `Customer` model for account linking.

### B. New Middleware & Auth Mechanics:
1. **`server/middleware/customerAuthMiddleware.js`**:
   - `signCustomerToken(payload)`: Signs 30-day JWT tokens with `{ role: 'customer' }`.
   - `customerAuth`: Protects customer endpoints. Verifies `decoded.role === 'customer'`, checks account status, and attaches `req.customer`.
   - `optionalCustomerAuth`: Allows guest checkouts on `/api/orders` while attaching `req.customer` if a valid customer token is supplied.

### C. New Route Modules Implemented:
1. **`server/routes/customerAuthRoutes.js`**:
   - `POST /api/customer/auth/send-otp` (Validates 10-digit mobile number, generates 6-digit OTP, stores expiry).
   - `POST /api/customer/auth/verify-otp` (Verifies OTP, auto-creates customer if new, updates `lastLoginAt`, returns 30-day JWT token & safe customer object).
2. **`server/routes/customerProfileRoutes.js`**:
   - `GET /api/customer/profile` (Returns sanitized customer profile).
   - `PATCH /api/customer/profile` (Updates `name`, `email`, `avatar`; protects `phone` & `_id`).
3. **`server/routes/customerAddressRoutes.js`**:
   - `GET /api/customer/addresses` (Lists customer saved addresses).
   - `POST /api/customer/addresses` (Adds new address; manages default address flag).
   - `PATCH /api/customer/addresses/:addressId` (Updates address details or default status).
   - `DELETE /api/customer/addresses/:addressId` (Deletes address with default fallback).
4. **`server/routes/customerOrderRoutes.js`**:
   - `GET /api/customer/orders` (Queries customer order history by `customerRef` OR `customer.phone` for seamless legacy order access).
   - `GET /api/customer/orders/:orderId` (Retrieves single order detail with strict cross-customer isolation check returning `403 Forbidden` if accessed by another user).
5. **`server/routes/customerReviewRoutes.js`**:
   - `POST /api/customer/reviews` (Allows customer to submit reviews for delivered orders with rating validation and duplicate prevention).

### D. Route Enhancements & Bug Fixes:
1. **`server/routes/orderRoutes.js`**:
   - **Fixed Step 18 Issue:** Added missing `import Service from '../models/Service.js';` to prevent runtime `ReferenceError`.
   - **Server-Side Price Validation:** Backend now recalculates order totals using live MongoDB `Service` prices, ignoring tampered prices sent by clients.
   - **Customer Account Linking:** Attaches `customerRef` if request comes from an authenticated mobile customer.
   - **Guest Web Compatibility:** Unauthenticated website guest orders remain fully supported.

---

## 3. Server Route Mounts in `server/server.js`

```javascript
// Customer Mobile App Routes
app.use('/api/customer/auth', customerAuthRoutes);
app.use('/api/customer/profile', customerProfileRoutes);
app.use('/api/customer/addresses', customerAddressRoutes);
app.use('/api/customer/orders', customerOrderRoutes);
app.use('/api/customer/reviews', customerReviewRoutes);
```

---

## 4. Security & Data Protection Measures

- **Password & OTP Safety:** No plain-text credentials stored. OTP secrets hidden with `select: false`.
- **JWT Secret Enforcement:** JWT secrets loaded from `process.env.JWT_SECRET` with fallback defaults.
- **Cross-Customer Data Isolation:** Customer B cannot view or modify Customer A's addresses or order details (enforced via ownership checks returning 403/404).
- **Server Price Validation:** Prevents client-side price tampering.

---

## 5. Website Compatibility Confirmation

All existing website endpoints were tested and verified:
- `GET /api/services` (Public Laundry Services) — PASSED
- `GET /api/reviews` (Public Approved Reviews) — PASSED
- `POST /api/orders` (Guest Checkout) — PASSED
- `POST /api/auth/login` (Admin Login) — PASSED
- `GET /api-status` (API Health Check) — PASSED

---

## 6. Files Changed in Phase 3A

- **Created:**
  - `server/models/Customer.js`
  - `server/middleware/customerAuthMiddleware.js`
  - `server/routes/customerAuthRoutes.js`
  - `server/routes/customerProfileRoutes.js`
  - `server/routes/customerAddressRoutes.js`
  - `server/routes/customerOrderRoutes.js`
  - `server/routes/customerReviewRoutes.js`
- **Modified:**
  - `server/models/Order.js` (Added optional `customerRef` field)
  - `server/routes/orderRoutes.js` (Fixed `Service` import, server price validation, optional customer auth)
  - `server/server.js` (Imported and mounted customer routes)

---

## 7. Recommended Next Step

Proceed to **Phase 3B — Flutter Application Creation & Initial Setup**.
