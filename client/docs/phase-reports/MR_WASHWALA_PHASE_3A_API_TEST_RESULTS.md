# MR. WASHWALA — PHASE 3A: API INTEGRATION TEST RESULTS

**Project:** Mr. WashWala Laundry Booking System  
**Date:** October 6, 2026  
**Test Suite Status:** 25 / 25 PASSED (100% SUCCESS)  

---

## Complete API Integration Test Log

| # | Test Name | Target Endpoint | Expected Result | Actual Result | Status |
| :-: | :--- | :--- | :--- | :--- | :-: |
| 1 | Send OTP (Valid Phone) | `POST /api/customer/auth/send-otp` | HTTP 200, OTP sent message | `OTP sent successfully to 9876543210` | **PASSED** |
| 2 | Send OTP (Invalid Phone) | `POST /api/customer/auth/send-otp` | HTTP 400 Bad Request | `Please enter a valid 10-digit mobile number` | **PASSED** |
| 3 | Verify OTP & Register Customer A | `POST /api/customer/auth/verify-otp` | HTTP 200, JWT token returned | `Token obtained for Customer A` | **PASSED** |
| 4 | Verify OTP (Invalid OTP Code) | `POST /api/customer/auth/verify-otp` | HTTP 401 Unauthorized | `Invalid or expired OTP` | **PASSED** |
| 5 | Request Profile (Missing Token) | `GET /api/customer/profile` | HTTP 401 Unauthorized | `Authorization token missing` | **PASSED** |
| 6 | Request Profile (Invalid Token) | `GET /api/customer/profile` | HTTP 401 Unauthorized | `Invalid or expired authorization token` | **PASSED** |
| 7 | Get Customer A Profile | `GET /api/customer/profile` | HTTP 200, Customer A data | `Retrieved profile for Customer A (9876543210)` | **PASSED** |
| 8 | Update Customer A Profile | `PATCH /api/customer/profile` | HTTP 200, updated profile | `Profile updated successfully` | **PASSED** |
| 9 | Protect Field Update (Phone) | `PATCH /api/customer/profile` | Phone remains unchanged | `Phone remained protected` | **PASSED** |
| 10 | Add Delivery Address | `POST /api/customer/addresses` | HTTP 201, address object | `Added address addr-1791282304848-btv6h` | **PASSED** |
| 11 | Get Saved Addresses | `GET /api/customer/addresses` | HTTP 200, count = 1 | `Count: 1` | **PASSED** |
| 12 | Update Address Label/Default | `PATCH /api/customer/addresses/:id` | HTTP 200, label updated | `Address updated successfully` | **PASSED** |
| 13 | Address Cross-Customer Isolation | `DELETE /api/customer/addresses/:id` | HTTP 404 Not Found (Denied B) | `Isolation verified: 404 Not Found` | **PASSED** |
| 14 | Delete Address | `DELETE /api/customer/addresses/:id` | HTTP 200, address removed | `Address removed successfully` | **PASSED** |
| 15 | Create Order & Price Validation | `POST /api/orders` | HTTP 201, recalculated total ₹180 | `Created order MRW-559556 with server total ₹180` | **PASSED** |
| 16 | Fetch Customer Order History | `GET /api/customer/orders` | HTTP 200, order array | `Found 1 orders for Customer A` | **PASSED** |
| 17 | Fetch Single Order Details | `GET /api/customer/orders/:orderId` | HTTP 200, order detail | `Retrieved order detail for MRW-559556` | **PASSED** |
| 18 | Order Cross-Customer Isolation | `GET /api/customer/orders/:orderId` | HTTP 403 Forbidden (Denied B) | `Isolation verified: 403 Forbidden` | **PASSED** |
| 19 | Reject Order (Missing Customer) | `POST /api/orders` | HTTP 400 Bad Request | `Customer details (name, phone, address) are required` | **PASSED** |
| 20 | Reject Order (Empty Items) | `POST /api/orders` | HTTP 400 Bad Request | `Cart items are required` | **PASSED** |
| 21 | Deny Review Non-Delivered Order | `POST /api/customer/reviews` | HTTP 400 Bad Request | `Only delivered orders can be reviewed` | **PASSED** |
| 22 | Submit Review Delivered Order | `POST /api/customer/reviews` | HTTP 201, review object | `Review submitted successfully` | **PASSED** |
| 23 | Reject Review Invalid Rating | `POST /api/customer/reviews` | HTTP 400 Bad Request | `Rating must be an integer between 1 and 5` | **PASSED** |
| 24 | Website Public Services Check | `GET /api/services` | HTTP 200, services array | `Services fetched: 36` | **PASSED** |
| 25 | Website Unauth Guest Checkout | `POST /api/orders` | HTTP 201, order created | `Guest order created successfully (MRW-828272)` | **PASSED** |

---

## Test Summary Stats

- **Total API Tests Conducted:** 25
- **Passed:** 25
- **Failed:** 0
- **Pass Rate:** 100%
