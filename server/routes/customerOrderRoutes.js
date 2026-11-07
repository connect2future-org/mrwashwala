import express from 'express';
import Order from '../models/Order.js';
import { customerAuth } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

router.use(customerAuth);

// @desc    Get order history for authenticated customer
// @route   GET /api/customer/orders
// @access  Customer
router.get('/', async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.max(1, Math.min(50, parseInt(req.query.limit, 10) || 10));
    const statusFilter = req.query.status;

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
    const totalPages = Math.ceil(totalOrders / limit) || 1;

    const orders = await Order.find(filter)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    res.json({
      success: true,
      count: orders.length,
      totalOrders,
      page,
      totalPages,
      data: orders
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch customer order history', error: error.message });
  }
});

// @desc    Get single order detail by orderId for authenticated customer
// @route   GET /api/customer/orders/:orderId
// @access  Customer
router.get('/:orderId', async (req, res) => {
  try {
    const order = await Order.findOne({ orderId: req.params.orderId }).lean();
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Security Check: Customer can only access their own order
    const customerId = req.customer._id.toString();
    const customerPhone = req.customer.phone;
    const orderCustomerRef = order.customerRef ? order.customerRef.toString() : null;

    const isOwner = orderCustomerRef === customerId || order.customer?.phone === customerPhone;
    if (!isOwner) {
      return res.status(403).json({ success: false, message: 'Forbidden: You do not have permission to view this order' });
    }

    res.json({
      success: true,
      data: order
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch order details', error: error.message });
  }
});

export default router;
