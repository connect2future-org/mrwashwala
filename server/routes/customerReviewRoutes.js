import express from 'express';
import Review from '../models/Review.js';
import Order from '../models/Order.js';
import { customerAuth } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

router.use(customerAuth);

// @desc    Get all reviews submitted by the logged-in customer
// @route   GET /api/customer/reviews
// @access  Customer
router.get('/', async (req, res) => {
  try {
    const customer = req.customer;
    const authorName = customer.name?.trim() || `Customer (${customer.phone.slice(-4)})`;

    const reviews = await Review.find({
      $or: [
        { author: authorName },
        { text: new RegExp(customer.phone, 'i') }
      ]
    }).sort({ reviewDate: -1 }).lean();

    res.json({
      success: true,
      count: reviews.length,
      data: reviews
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch customer reviews',
      error: error.message
    });
  }
});

// @desc    Submit a review for a completed/delivered order
// @route   POST /api/customer/reviews
// @access  Customer
router.post('/', async (req, res) => {
  try {
    const { rating, text, orderId } = req.body;
    const customer = req.customer;

    if (!text || String(text).trim().length < 5) {
      return res.status(400).json({
        success: false,
        message: 'Review text must be at least 5 characters long'
      });
    }

    const numericRating = Number(rating);
    if (![1, 2, 3, 4, 5].includes(numericRating)) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be an integer between 1 and 5'
      });
    }

    let branch = null;

    if (orderId && String(orderId).trim()) {
      const order = await Order.findOne({ orderId: String(orderId).trim() });
      if (!order) {
        return res.status(404).json({ success: false, message: 'Associated order not found' });
      }

      const isOwner =
        (order.customerRef && order.customerRef.toString() === customer._id.toString()) ||
        order.customer?.phone === customer.phone;

      if (!isOwner) {
        return res.status(403).json({ success: false, message: 'Forbidden: You can only review your own orders' });
      }

      if (order.status !== 'Delivered') {
        return res.status(400).json({
          success: false,
          message: 'Only delivered orders can be reviewed'
        });
      }

      // Check duplicate review for this order
      const existingReview = await Review.findOne({ text: new RegExp(order.orderId, 'i') });
      if (existingReview) {
        return res.status(400).json({
          success: false,
          message: 'You have already submitted a review for this order'
        });
      }

      if (order.selectedBranch) {
        branch = { id: order.selectedBranch.id, name: order.selectedBranch.name };
      }
    }

    const authorName = customer.name?.trim() || `Customer (${customer.phone.slice(-4)})`;
    const reviewText = orderId ? `[Order ${orderId}] ${text.trim()}` : text.trim();

    const review = await Review.create({
      author: authorName,
      rating: numericRating,
      text: reviewText,
      approved: true,
      hidden: false,
      source: 'api',
      branch: branch || undefined
    });

    res.status(201).json({
      success: true,
      message: 'Review submitted successfully',
      data: review
    });
  } catch (error) {
    console.error('Customer review submission error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to submit review',
      error: error.message
    });
  }
});

export default router;
