import express from 'express';
import { customerAuth } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

router.use(customerAuth);

// @desc    Get customer profile
// @route   GET /api/customer/profile
// @access  Customer
router.get('/', async (req, res) => {
  try {
    const customer = req.customer.toObject();
    delete customer.otpSecret;
    delete customer.otpExpiresAt;

    res.json({
      success: true,
      data: customer
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch customer profile', error: error.message });
  }
});

// @desc    Update customer profile
// @route   PATCH /api/customer/profile
// @access  Customer
router.patch('/', async (req, res) => {
  try {
    const { name, email, avatar } = req.body;
    const customer = req.customer;

    if (name !== undefined) customer.name = String(name).trim();
    if (email !== undefined) customer.email = String(email).trim().toLowerCase();
    if (avatar !== undefined) customer.avatar = avatar;

    const updated = await customer.save();
    const safeData = updated.toObject();
    delete safeData.otpSecret;
    delete safeData.otpExpiresAt;

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: safeData
    });
  } catch (error) {
    res.status(400).json({ success: false, message: 'Failed to update customer profile', error: error.message });
  }
});

export default router;
