import express from 'express';
import { customerAuth } from '../middleware/customerAuthMiddleware.js';

const router = express.Router();

router.use(customerAuth);

// @desc    Get all saved addresses for logged-in customer
// @route   GET /api/customer/addresses
// @access  Customer
router.get('/', async (req, res) => {
  try {
    res.json({
      success: true,
      count: req.customer.addresses.length,
      data: req.customer.addresses
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch saved addresses', error: error.message });
  }
});

// @desc    Add a new delivery address
// @route   POST /api/customer/addresses
// @access  Customer
router.post('/', async (req, res) => {
  try {
    const {
      label = 'Home',
      fullAddress,
      houseNo = '',
      street = '',
      landmark = '',
      city = 'Mysuru',
      pincode = '',
      latitude = null,
      longitude = null,
      isDefault = false
    } = req.body;

    if (!fullAddress || !fullAddress.trim()) {
      return res.status(400).json({ success: false, message: 'Full address is required' });
    }

    const customer = req.customer;
    const addressId = `addr-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`;

    // If setting as default, clear default from existing addresses
    if (isDefault || customer.addresses.length === 0) {
      customer.addresses.forEach(addr => {
        addr.isDefault = false;
      });
    }

    const newAddress = {
      addressId,
      label: ['Home', 'Work', 'Other'].includes(label) ? label : 'Home',
      fullAddress: fullAddress.trim(),
      houseNo: houseNo.trim(),
      street: street.trim(),
      landmark: landmark.trim(),
      city: city.trim(),
      pincode: pincode.trim(),
      latitude: Number.isFinite(Number(latitude)) ? Number(latitude) : null,
      longitude: Number.isFinite(Number(longitude)) ? Number(longitude) : null,
      isDefault: isDefault || customer.addresses.length === 0
    };

    customer.addresses.push(newAddress);
    await customer.save();

    res.status(201).json({
      success: true,
      message: 'Address added successfully',
      data: newAddress,
      addresses: customer.addresses
    });
  } catch (error) {
    res.status(400).json({ success: false, message: 'Failed to add address', error: error.message });
  }
});

// @desc    Update a saved address or set it as default
// @route   PATCH /api/customer/addresses/:addressId
// @access  Customer
router.patch('/:addressId', async (req, res) => {
  try {
    const { addressId } = req.params;
    const updates = req.body;
    const customer = req.customer;

    const targetAddress = customer.addresses.find(a => a.addressId === addressId);
    if (!targetAddress) {
      return res.status(404).json({ success: false, message: 'Address not found' });
    }

    if (updates.isDefault === true) {
      customer.addresses.forEach(addr => {
        addr.isDefault = false;
      });
      targetAddress.isDefault = true;
    }

    if (updates.label !== undefined) targetAddress.label = updates.label;
    if (updates.fullAddress !== undefined) targetAddress.fullAddress = updates.fullAddress.trim();
    if (updates.houseNo !== undefined) targetAddress.houseNo = updates.houseNo.trim();
    if (updates.street !== undefined) targetAddress.street = updates.street.trim();
    if (updates.landmark !== undefined) targetAddress.landmark = updates.landmark.trim();
    if (updates.city !== undefined) targetAddress.city = updates.city.trim();
    if (updates.pincode !== undefined) targetAddress.pincode = updates.pincode.trim();
    if (updates.latitude !== undefined) targetAddress.latitude = updates.latitude;
    if (updates.longitude !== undefined) targetAddress.longitude = updates.longitude;

    await customer.save();

    res.json({
      success: true,
      message: 'Address updated successfully',
      data: targetAddress,
      addresses: customer.addresses
    });
  } catch (error) {
    res.status(400).json({ success: false, message: 'Failed to update address', error: error.message });
  }
});

// @desc    Delete a saved address
// @route   DELETE /api/customer/addresses/:addressId
// @access  Customer
router.delete('/:addressId', async (req, res) => {
  try {
    const { addressId } = req.params;
    const customer = req.customer;

    const initialLength = customer.addresses.length;
    customer.addresses = customer.addresses.filter(a => a.addressId !== addressId);

    if (customer.addresses.length === initialLength) {
      return res.status(404).json({ success: false, message: 'Address not found' });
    }

    // If default address was deleted and others remain, set first as default
    if (customer.addresses.length > 0 && !customer.addresses.some(a => a.isDefault)) {
      customer.addresses[0].isDefault = true;
    }

    await customer.save();

    res.json({
      success: true,
      message: 'Address removed successfully',
      addresses: customer.addresses
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete address', error: error.message });
  }
});

export default router;
