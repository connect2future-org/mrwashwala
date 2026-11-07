import express from 'express';
import Customer from '../models/Customer.js';
import { signCustomerToken } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

// Helper to normalize 10-digit Indian mobile numbers
const normalizePhone = (phone) => {
  if (!phone) return '';
  const digits = String(phone).replace(/\D/g, '');
  if (digits.length === 10) return digits;
  if (digits.length === 12 && digits.startsWith('91')) return digits.slice(2);
  return digits;
};

// @desc    Send 6-digit OTP to customer mobile number
// @route   POST /api/customer/auth/send-otp
// @access  Public
router.post('/send-otp', async (req, res) => {
  try {
    const rawPhone = req.body.phone;
    const phone = normalizePhone(rawPhone);

    if (!phone || !/^\d{10}$/.test(phone)) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid 10-digit mobile number'
      });
    }

    // Generate 6-digit OTP. In development or without paid gateway, default '123456' is accepted
    const isDev = process.env.NODE_ENV !== 'production';
    const otp = isDev ? '123456' : Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    let customer = await Customer.findOne({ phone }).select('+otpSecret +otpExpiresAt');
    if (!customer) {
      customer = new Customer({
        phone,
        otpSecret: otp,
        otpExpiresAt: expiresAt
      });
    } else {
      customer.otpSecret = otp;
      customer.otpExpiresAt = expiresAt;
    }

    await customer.save();

    console.log(`[OTP SERVICE] OTP for customer ${phone} is ${otp}`);

    return res.status(200).json({
      success: true,
      message: `OTP sent successfully to ${phone}`,
      expiresInSeconds: 300,
      // Provide OTP in dev mode for easy test execution
      devNote: isDev ? 'Development Mode: Use OTP 123456' : undefined
    });
  } catch (error) {
    console.error('Send OTP error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to send OTP',
      error: error.message
    });
  }
});

// @desc    Verify OTP and authenticate/register customer
// @route   POST /api/customer/auth/verify-otp
// @access  Public
router.post('/verify-otp', async (req, res) => {
  try {
    const { otp, name } = req.body;
    const phone = normalizePhone(req.body.phone);

    if (!phone || !/^\d{10}$/.test(phone)) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid 10-digit mobile number'
      });
    }

    if (!otp || String(otp).trim().length !== 6) {
      return res.status(400).json({
        success: false,
        message: 'Please enter a valid 6-digit OTP'
      });
    }

    const customer = await Customer.findOne({ phone }).select('+otpSecret +otpExpiresAt');
    if (!customer) {
      return res.status(401).json({
        success: false,
        message: 'No OTP requested for this phone number. Please click Send OTP.'
      });
    }

    if (customer.isActive === false) {
      return res.status(403).json({
        success: false,
        message: 'Customer account is disabled. Please contact support.'
      });
    }

    const isDev = process.env.NODE_ENV !== 'production';
    const isDevOtp = isDev && String(otp).trim() === '123456';
    const isOtpValid = customer.otpSecret === String(otp).trim() || isDevOtp;
    const isNotExpired = customer.otpExpiresAt && new Date() < new Date(customer.otpExpiresAt);

    if (!isOtpValid || (!isNotExpired && !isDevOtp)) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired OTP. Please request a new one.'
      });
    }

    const isNewCustomer = !customer.name && !customer.lastLoginAt;
    if (name && name.trim()) {
      customer.name = name.trim();
    }
    customer.lastLoginAt = new Date();
    customer.otpSecret = undefined;
    customer.otpExpiresAt = undefined;

    await customer.save();

    const token = signCustomerToken({
      id: customer._id,
      phone: customer.phone
    });

    const safeCustomer = customer.toObject();
    delete safeCustomer.otpSecret;
    delete safeCustomer.otpExpiresAt;

    return res.status(200).json({
      success: true,
      message: 'Authentication successful',
      token,
      isNewCustomer,
      customer: safeCustomer
    });
  } catch (error) {
    console.error('Verify OTP error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Failed to verify OTP',
      error: error.message
    });
  }
});

export default router;
