import jwt from 'jsonwebtoken';
import Customer from '../models/Customer.js';

const getJwtSecret = () => process.env.JWT_SECRET || 'mrwashwala_secret_change_this';
const getJwtExpiry = () => process.env.CUSTOMER_JWT_EXPIRES_IN || '30d';

export const signCustomerToken = (payload) => {
  return jwt.sign(
    { ...payload, role: 'customer' },
    getJwtSecret(),
    { expiresIn: getJwtExpiry() }
  );
};

export const customerAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authorization token missing' });
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return res.status(401).json({ success: false, message: 'Authorization token missing' });
    }

    const decoded = jwt.verify(token, getJwtSecret());
    if (decoded.role !== 'customer') {
      return res.status(403).json({ success: false, message: 'Forbidden: customer access required' });
    }

    const customer = await Customer.findById(decoded.id);
    if (!customer) {
      return res.status(401).json({ success: false, message: 'Customer account not found' });
    }

    if (customer.isActive === false) {
      return res.status(403).json({ success: false, message: 'Customer account is disabled' });
    }

    req.customer = customer;
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Customer auth error:', error.message);
    return res.status(401).json({ success: false, message: 'Invalid or expired authorization token' });
  }
};

export const optionalCustomerAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || req.headers.Authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      return next();
    }

    const decoded = jwt.verify(token, getJwtSecret());
    if (decoded.role === 'customer') {
      const customer = await Customer.findById(decoded.id);
      if (customer && customer.isActive !== false) {
        req.customer = customer;
        req.user = decoded;
      }
    }
    next();
  } catch (error) {
    // Silent fallback for guest checkouts
    next();
  }
};
