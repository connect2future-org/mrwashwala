# MR. WASHWALA — PHASE 4B STEP 4
## Checkout + Address + Pickup Schedule + Branch + Payment + Order Creation Report

**Document Version:** 1.0.0  
**Date:** October 7, 2026  
**Status:** STEP 4 COMPLETE & VERIFIED  
**Target App:** `mrwashwala-mobile` (Flutter 3.47.6 / Dart 3.13.5)  
**Backend:** Existing Node.js / Express Backend (Port 5000)  
**Database:** Existing MongoDB (Untouched)  

---

## 1. Executive Summary

Phase 4B Step 4 implements the complete, real checkout and order booking flow in the **Mr. WashWala Flutter Mobile Application**. The mobile app now allows customers to proceed from their local cart into checkout, select or add delivery addresses via backend customer address APIs (`/api/customer/addresses`), schedule pickup date and time slots, select an assigned processing outlet branch, choose payment methods (Cash on Delivery or UPI), review order items and totals, submit booking requests directly to `POST /api/orders`, and view the order success screen displaying real order IDs returned by MongoDB (`MRW-XXXXXX`).

---

## 2. APIs Used & Payload Structure

### 1. Order Creation Endpoint (`POST /api/orders`)
- **Headers:** Optional `Authorization: Bearer <token>` (links order to `customerRef` if authenticated).
- **Exact Payload Schema:**
  ```json
  {
    "customer": {
      "name": "Jane Doe",
      "phone": "9876543210",
      "address": "123 Main Street, Jayalakshmipuram, Mysuru"
    },
    "items": [
      {
        "name": "Wash & Fold",
        "quantity": 5,
        "price": 59,
        "unit": "kg"
      }
    ],
    "totalAmount": 295,
    "pickupDate": "2026-10-10",
    "pickupTime": "10:00 AM - 12:00 PM",
    "paymentMethod": "Cash on Delivery",
    "paymentStatus": "Pending",
    "selectedBranch": {
      "id": "vijaynagar-mysuru",
      "name": "Vijaynagar Outlet, Mysuru"
    },
    "recommendedBranch": {
      "id": "vijaynagar-mysuru",
      "name": "Vijaynagar Outlet, Mysuru"
    }
  }
  ```
- **Response `201 Created`:**
  ```json
  {
    "_id": "6702d8f9...",
    "orderId": "MRW-583920",
    "status": "Pending",
    "totalAmount": 295,
    "paymentMethod": "Cash on Delivery",
    "pickupDate": "2026-10-10",
    "pickupTime": "10:00 AM - 12:00 PM",
    "createdAt": "2026-10-07T14:15:00.000Z"
  }
  ```

### 2. Customer Saved Addresses Endpoints
- **Fetch Addresses (`GET /api/customer/addresses`):** Retrieves saved customer delivery locations.
- **Add Address (`POST /api/customer/addresses`):** Adds a new delivery address (`label`, `fullAddress`, `houseNo`, `street`, `landmark`, `pincode`).

---

## 3. Checkout Flow Implementation

1. **Cart Screen -> Checkout Screen:**
   - Tapping "Proceed to Checkout" opens `CheckoutScreen`.
2. **Customer Contact Section:**
   - Auto-populates customer name and mobile phone from `AuthController`. Allows manual entry for guest checkouts.
3. **Delivery Address Section:**
   - Displays saved customer addresses with radio selectors.
   - Includes "Add New Address" modal dialog (`AddAddressDialog`) that persists new addresses directly to the backend.
4. **Pickup Schedule Section:**
   - Native Flutter `showDatePicker` (restricts selection to current/future dates up to 30 days ahead).
   - Pickup time slot chips (`09:00 AM - 11:00 AM`, `11:00 AM - 01:00 PM`, `02:00 PM - 04:00 PM`, `04:00 PM - 06:00 PM`, `06:00 PM - 08:00 PM`).
5. **Branch Selection Section:**
   - Dropdown menu for outlet branch selection (`Vijaynagar Outlet, Mysuru`, `Kuvempunagar Outlet`, `Saraswathipuram Outlet`). Defaults to primary Mysuru branch `vijaynagar-mysuru`.
6. **Payment Method Section:**
   - Cash on Delivery (`Cash on Delivery`) - Default active flow.
   - UPI / QR Payment (`QR Payment`) - Active flow.
   - Online Payment (`Online Payment`) - Displayed with status note: `PENDING PROVIDER CONFIGURATION`.
7. **Order Submission & Duplicate Protection:**
   - Disables "Place Order" button and shows progress spinner while order request is active.
   - Prevents duplicate order creation from rapid repeated button taps.
8. **Cart Clearing & Success Screen:**
   - **Cart cleared ONLY AFTER successful order creation (`201 Created`).**
   - If order creation fails (e.g. network timeout or 500 error), the cart items are preserved so the user can retry.
   - Navigates to `OrderSuccessScreen` displaying the real backend-generated order ID (`MRW-XXXXXX`), pickup schedule, and summary.

---

## 4. Files Created & Modified

### Created in `mrwashwala-mobile`:
- `lib/data/models/order_model.dart`
- `lib/data/repositories/address_repository.dart`
- `lib/data/repositories/order_repository.dart`
- `lib/features/checkout/presentation/checkout_controller.dart`
- `lib/features/checkout/presentation/checkout_screen.dart`
- `lib/features/addresses/presentation/add_address_dialog.dart`
- `lib/features/orders/presentation/order_success_screen.dart`
- `test/data/order_repository_test.dart`
- `test/features/checkout_controller_test.dart`

### Modified in `mrwashwala-mobile`:
- `lib/features/cart/presentation/cart_screen.dart` (Updated "Proceed to Checkout" button to navigate to `CheckoutScreen`)

### Server & Website Files Modified:
- **NONE** (Zero modifications to `client/`, `server/`, or MongoDB).

---

## 5. Verification & Test Results

- **`flutter analyze`:** `PASS (0 errors, 0 warnings)`
- **`flutter test`:** `PASS (All 23 tests passed)`
- **Android Emulator Runtime:** Running on `emulator-5554` connected to local Express server (`http://10.0.2.2:5000/api`).
- **Real Order Creation Verified:** Confirmed `POST /api/orders` creates real orders in MongoDB with status `Pending` and generates real `MRW-XXXXXX` order IDs.
- **Cart Protection Verified:** Confirmed cart is preserved on API error and cleared only on `201 Created`.

---

## 6. Known Limitations & Online Payment Status

- **Online Payment Status:** `NOT ENABLED / PENDING PROVIDER CONFIGURATION`. Razorpay/PhonePe gateway integration requires setting production merchant secrets in backend `.env` before enabling SDK checkout in mobile. COD and UPI QR payment flows are fully functional.

---

## 7. Next Implementation Steps (Phase 4B Step 5)

When instructed, the next step will implement:
- **Customer Order History & Order Details Screen (`GET /api/customer/orders` & `GET /api/customer/orders/:orderId`)**: Displaying active order status tracking (`Pending`, `Processing`, `Out for Delivery`, `Delivered`) and order history list in the mobile app.

---
*End of Phase 4B Step 4 Report*
