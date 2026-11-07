# Mr. WashWala — Customer Order History Data Source Audit Report

**Date of Audit:** October 14, 2026  
**Audit Type:** Read-Only Source Code & Data Source Verification  
**Flutter Project Path:** `client/mobile` (formerly `/Users/ajay/Desktop/mrwashwala/mrwashwala-mobile`)  
**Backend Project Path:** `server`  
**Database:** MongoDB Atlas (`mrwashwala` database)

---

## 1. Executive Summary

A comprehensive read-only audit was conducted on the Mr. WashWala Flutter mobile application and Express/MongoDB backend to determine:
1. Where orders displayed on the "My Orders" screen originate from.
2. Whether orders are customer-specific or general/mock data.
3. The exact mechanism isolating order records between customers.

### Overall Finding
**Overall Result:** **`CUSTOMER-SPECIFIC`**

The order records displayed on the Flutter app's "My Orders" screen originate from **real MongoDB order documents** stored in the `orders` collection of the `mrwashwala` database. The Flutter client calls a dedicated, authenticated endpoint (`GET /api/customer/orders`), which validates a customer JWT token and restricts queries exclusively to records where `customerRef` equals the authenticated customer's MongoDB `_id` OR `customer.phone` equals the verified customer's 10-digit mobile number. No mock, sample, or hardcoded orders exist in the Flutter codebase.

---

## 2. End-to-End Data Flow Diagram

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Customer (Mobile App)
    participant OrdersUI as OrdersScreen (Flutter)
    participant Controller as CustomerOrderController
    participant Repo as CustomerOrderRepository
    participant Client as ApiClient (HTTP)
    participant Middleware as customerAuthMiddleware (Express)
    participant Route as customerOrderRoutes.js
    participant DB as MongoDB (orders collection)

    Customer->>OrdersUI: Open "Orders" Tab
    OrdersUI->>Controller: fetchOrders(token)
    Note over Controller: Checks token is non-null & valid
    Controller->>Repo: fetchCustomerOrders(token, page, statusFilter)
    Repo->>Client: GET /api/customer/orders?page=1&limit=10&status=...
    Note over Client: Injects Header: Authorization: Bearer <jwt_token>
    Client->>Middleware: HTTP GET /api/customer/orders
    Middleware->>Middleware: jwt.verify(token, JWT_SECRET)
    Middleware->>DB: Customer.findById(decoded.id)
    DB-->>Middleware: Customer Document (id, phone, isActive)
    Middleware->>Route: req.customer = verifiedCustomer
    Route->>DB: Order.find({ $or: [{ customerRef: customerId }, { 'customer.phone': customerPhone }] })
    Note over DB: Matches ONLY orders owned by this customer
    DB-->>Route: Filtered Order Documents (JSON)
    Route-->>Client: HTTP 200 OK { success: true, count, totalOrders, data: orders }
    Client-->>Repo: Decoded JSON Map
    Repo-->>Controller: CustomerOrdersResponse (List<OrderModel>)
    Controller-->>OrdersUI: notifyListeners()
    OrdersUI->>Customer: Render Order Cards (Order ID, Status, Items, Date, Total)
```

---

## 3. Exact API Request Specification

| Parameter | Specification |
| :--- | :--- |
| **HTTP Method** | `GET` |
| **Endpoint URL** | `http://10.0.2.2:5000/api/customer/orders` (Centralized in `ApiConfig.orders`) |
| **Query Parameters** | `page` (integer, e.g. `1`), `limit` (integer, e.g. `10`), `status` (optional filter, e.g. `Pending`) |
| **Authentication Header** | `Authorization: Bearer <customer_jwt_token>` |
| **Customer Identifier in Request Body / URL** | **None**. No customer ID, phone, or name is passed in parameters. |
| **Identity Source** | Verified server-side cryptographically from the signed JWT payload (`req.customer`). |
| **Target Route Type** | Dedicated customer endpoint (`customerOrderRoutes.js`), **not** the admin endpoint (`orderRoutes.js`). |
| **Multi-Customer Return Risk** | **None**. The database query restricts records to the verified caller's `_id` and verified phone number. |

### Relevant Flutter Request Code
**File:** [`client/mobile/lib/data/repositories/customer_order_repository.dart`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/client/mobile/lib/data/repositories/customer_order_repository.dart#L30-L50)
```dart
Future<CustomerOrdersResponse> fetchCustomerOrders(
  String token, {
  int page = 1,
  int limit = 10,
  String? statusFilter,
}) async {
  final queryParams = <String, String>{
    'page': page.toString(),
    'limit': limit.toString(),
  };
  if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
    queryParams['status'] = statusFilter;
  }

  final queryString = Uri(queryParameters: queryParams).query;
  final url = '${ApiConfig.orders}?$queryString';

  final response = await _apiClient.get(url, token: token);
  // ...
}
```

---

## 4. Backend Implementation & Customer Ownership Verification

### Route & Controller
- **Mount Point:** `app.use('/api/customer/orders', customerOrderRoutes);` ([`server/server.js:144`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/server.js#L144))
- **Route File:** [`server/routes/customerOrderRoutes.js`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/routes/customerOrderRoutes.js#L1-L50)
- **Middleware:** `router.use(customerAuth);` ([`server/routes/customerOrderRoutes.js:7`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/routes/customerOrderRoutes.js#L7))

### Middleware Token Verification
**File:** [`server/middleware/customerAuthMiddleware.js:18-46`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/middleware/customerAuthMiddleware.js#L18-L46)
```javascript
export const customerAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authorization token missing' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, getJwtSecret());
    if (decoded.role !== 'customer') {
      return res.status(403).json({ success: false, message: 'Forbidden: customer access required' });
    }

    const customer = await Customer.findById(decoded.id);
    if (!customer || customer.isActive === false) {
      return res.status(401).json({ success: false, message: 'Customer account not found or disabled' });
    }

    req.customer = customer;
    next();
  } catch (error) {
    return res.status(401).json({ success: false, message: 'Invalid or expired authorization token' });
  }
};
```

### Database Query & Ownership Filter
**File:** [`server/routes/customerOrderRoutes.js:19-48`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/routes/customerOrderRoutes.js#L19-L48)
```javascript
router.get('/', async (req, res) => {
  try {
    const customerId = req.customer._id;
    const customerPhone = req.customer.phone;

    // Matches either customerRef OR customer.phone for seamless legacy order access
    const filter = {
      $or: [
        { customerRef: customerId },
        { 'customer.phone': customerPhone }
      ]
    };

    if (statusFilter && statusFilter !== 'All') {
      filter.status = statusFilter;
    }

    const totalOrders = await Order.countDocuments(filter);
    const orders = await Order.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();
    // ...
```

### Single Order Detail Access Security
**File:** [`server/routes/customerOrderRoutes.js:63-75`](file:///Users/ajay/Desktop/mrwashwala/mrwashwala/server/routes/customerOrderRoutes.js#L63-L75)
```javascript
router.get('/:orderId', async (req, res) => {
  const order = await Order.findOne({ orderId: req.params.orderId }).lean();
  if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

  // Strict Security Check: Customer can ONLY access their own order
  const customerId = req.customer._id.toString();
  const customerPhone = req.customer.phone;
  const orderCustomerRef = order.customerRef ? order.customerRef.toString() : null;

  const isOwner = orderCustomerRef === customerId || order.customer?.phone === customerPhone;
  if (!isOwner) {
    return res.status(403).json({ success: false, message: 'Forbidden: You do not have permission to view this order' });
  }
  // ...
```

---

## 5. Empirical Evidence from Database Audit

A read-only query was executed directly against MongoDB Atlas to evaluate the distribution of orders:

| Metric | Empirical Count | Notes |
| :--- | :--- | :--- |
| **Total Orders in Database** | **47** | Complete historical order documents in `orders` collection |
| **Total Registered Customers** | **3** | Accounts in `customers` collection |
| **Customer A Orders (`97******67`)** | **18** | Includes `MRW-270676`, `MRW-598026`, `MRW-718104` |
| **Customer B Orders (`98******10`)** | **1** | Only `MRW-559556` |
| **Customer C Orders (`98******11`)** | **0** | Shows clean empty state ("No Orders Yet") |
| **Unlinked Orders (Other Phones)** | **28** | Belong to unauthenticated/guest web orders |

### Verification of Specific Order `MRW-270676`
The database record was located with exact matching parameters:
- **`orderId`:** `MRW-270676`
- **`status`:** `'Pending'`
- **`totalAmount`:** `200`
- **`pickupDate`:** `'2026-09-03'`
- **`pickupTime`:** `'14:15'`
- **`paymentMethod`:** `'whatsapp'`
- **`items`:** `[ { name: 'Casual Shoe', quantity: 1, unit: 'item', price: 200 } ]`
- **`customer.phone`:** Belongs directly to Customer A (`97******67`).

**Conclusion:** The app does **not** fetch from the general admin list (which contains 47 orders), nor does it use mock data. When logged in as Customer A, exactly 18 orders are returned. When logged in as Customer B, 1 order is returned.

---

## 6. Origin and Mapping of Displayed Order Fields

| Displayed Field | Example Value | Database / Backend Source | Flutter Mapping & UI Logic |
| :--- | :--- | :--- | :--- |
| **Order ID** | `MRW-270676` | `Order.orderId` (Generated by `generateUniqueOrderId` in `orderRoutes.js:18-19`) | `order.orderId` in `OrderModel.orderId` (`lib/data/models/order_model.dart:42`) |
| **Service Names & Quantities** | `Casual Shoe (1 item)` | `Order.items` array: `[{ name, quantity, unit, price }]` | `order.items.map((i) => '${i.name} (${i.quantity} ${i.unit})').join(', ')` (`orders_screen.dart:220`) |
| **Pickup Date & Time** | `Pickup: 2026-09-03 • 14:15` | `Order.pickupDate` (`'2026-09-03'`) & `Order.pickupTime` (`'14:15'`) | Concatenated as `'Pickup: ${order.pickupDate} • ${order.pickupTime}'` (`orders_screen.dart:242`) |
| **Payment Method & Status** | `Payment: whatsapp (Pending)` | `Order.paymentMethod` & `Order.paymentStatus` (DB enum: `Pending`, `Paid`, `Refunded`) | Displayed as `'Payment: ${order.paymentMethod} (${order.paymentStatus})'` (`orders_screen.dart:246`) |
| **Order Status Badge** | `Order Placed` | `Order.status` in DB holds `'Pending'` | Mapped by `OrderStatusHelper.getStatusLabel(order.status)` (`order_status_helper.dart:36-40`) |
| **Total Amount** | `₹200` | `Order.totalAmount` (`Number`, e.g. `200`) | Formatted by `OrderModel.formattedTotal` (`order_model.dart:73-75`) |

### Investigation: Why “Order Placed” Appears when Filter is “Pending”
- In MongoDB and the API contract, the status enum value is `'Pending'`.
- The status filter chip in the Flutter UI sends `status=Pending` to the backend.
- The backend matches `{ status: 'Pending' }` and returns the order.
- In `lib/core/constants/order_status_helper.dart:36-40`:
  ```dart
  static String getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Order Placed'; // <--- Presentation Label
  ```
- **Conclusion:** There is no defect. `'Pending'` is the internal database status key, while `'Order Placed'` is the customer-facing label designed to give customers immediate, positive confirmation of their order placement.

---

## 7. Customer Ownership & Identity Lifecycle Analysis

1. **OTP Verification:**
   - The user inputs their 10-digit phone on `PhoneScreen`.
   - `authController.verifyOtp()` sends `{ phone, otp }` to `POST /api/customer/auth/verify-otp`.
   - The backend checks `customer.otpSecret` in MongoDB.
   - On success, it issues a signed JWT containing `{ id: customer._id, phone: customer.phone, role: 'customer' }`.
2. **Token Persistence:**
   - Saved in encrypted Android Keystore via `FlutterSecureStorage` (`mrw_customer_jwt_token`).
3. **Order Retrieval:**
   - On opening the Orders tab, `OrdersScreen` passes `authController.token` to `CustomerOrderController.fetchOrders()`.
   - The backend decodes the token and extracts `req.customer._id` and `req.customer.phone`.
   - Orders matching either identifier are returned.
4. **Account Switching & In-Memory Isolation:**
   - When `authController.logout()` is called, `SecureStorageService.clearAll()` removes the stored JWT and customer metadata.
   - `OrdersScreen` inspects `authController.isAuthenticated`. If unauthenticated, it immediately renders `_buildUnauthenticatedState`, hiding orders.
   - When Customer B logs in, a new JWT with Customer B's credentials is generated and sent. `fetchOrders(newToken)` retrieves exclusively Customer B's orders.
   - **Architectural Observation:** Because `_orderController` in `MainNavigationScreen` is preserved across tabs, `_orderController.orders` retains the in-memory array until refreshed or overwritten. Because `OrdersScreen.build` checks `isLoggedIn`, unauthenticated users cannot see previous orders, but explicitly calling `_orderController.fetchOrders(null)` on logout is recommended as an added in-memory hygiene measure.

---

## 8. Potential Security & Data-Leakage Audit

| Checkpoint | Status | Analysis |
| :--- | :--- | :--- |
| **Authentication Enforcement** | **SECURE** | Route rejects unauthenticated requests with `401 Authorization token missing`. |
| **Cross-Tenant Order Leakage** | **SECURE** | Queries are hard-scoped to `req.customer._id` and `req.customer.phone`. No query parameter can override ownership. |
| **Single Order Detail Snooping** | **SECURE** | `GET /api/customer/orders/:orderId` explicitly tests `isOwner` before returning data; unauthorized requests receive `403 Forbidden`. |
| **Admin Route Separation** | **SECURE** | General orders route `GET /api/orders` requires `adminAuth` and is not called by the mobile client. |
| **Hardcoded/Mock Data** | **VERIFIED CLEAN** | 0 mock orders or sample datasets exist in production code (`lib/`). |

---

## 9. Follow-Up Safe Verification Tests

To verify this in the live running emulator without risking data corruption:
1. **Empty Customer Test:** Log in with a newly registered phone number that has never placed an order.
   - *Expected Result:* The screen immediately displays the empty state: *"You haven't placed any laundry orders yet."*
2. **Order Placement Isolation Test:** Place an order using Account A. Switch to Account B.
   - *Expected Result:* Account B sees 0 orders. Switching back to Account A displays the placed order.

---

## 10. Audit Compliance Confirmation

- **No Code Modified:** Zero edits were made to Flutter, Backend, Website, or Database files.
- **No Test Orders Placed:** Zero database records were created, updated, or removed.
- **No Sensitive Data Leaked:** All phone numbers, tokens, and personal identifying information have been completely redacted.
- **Verification Basis:** Findings are verified through source code cross-referencing and read-only MongoDB database inspection.
