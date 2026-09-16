import React, { useEffect, useState, useMemo } from 'react';
import API from '../api/api';

export default function DryCleaningModal({
  open,
  onClose,
  cart = [],
  onUpdateQuantity
}) {
  const [items, setItems] = useState([]);
  const [quantities, setQuantities] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [toast, setToast] = useState('');

  // Fetch active Dry Cleaning items from backend database
  useEffect(() => {
    if (!open) return;

    const fetchDryCleaningItems = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await API.get('/api/services', {
          params: { displayType: 'customize', customizeCategory: 'Dry Clean' }
        });
        
        let fetchedList = response.data || [];
        if (fetchedList.length === 0) {
          const allRes = await API.get('/api/services', { params: { displayType: 'customize' } });
          fetchedList = (allRes.data || []).filter(s => 
            (s.customizeCategory || '').toLowerCase().includes('dry') ||
            (s.id || '').startsWith('dryclean-')
          );
        }

        // Sort items by sortOrder
        fetchedList.sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
        setItems(fetchedList);

        // Sync local quantities with current cart
        const initialQtyMap = {};

        fetchedList.forEach(item => {
          const isVariantItem = item.hasStainRemoval || item.stainRemovalPrice > 0 || ['T-Shirt', 'Shirt', 'Pant'].includes(item.name);

          if (isVariantItem) {
            const normalName = `${item.name} - Normal Dry Cleaning`;
            const stainName = `${item.name} - Dry Cleaning + Stain Removal`;

            const normalCart = cart.find(c => c.name === normalName);
            const stainCart = cart.find(c => c.name === stainName);

            initialQtyMap[`${item.id}-normal`] = normalCart ? normalCart.quantity : 0;
            initialQtyMap[`${item.id}-stain`] = stainCart ? stainCart.quantity : 0;
          } else {
            const cartMatch = cart.find(c => c.name === item.name);
            initialQtyMap[item.id] = cartMatch ? cartMatch.quantity : 0;
          }
        });

        setQuantities(initialQtyMap);
      } catch (err) {
        console.error('Failed to load Dry Cleaning items:', err);
        setError('Unable to load Dry Cleaning items right now. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    fetchDryCleaningItems();
  }, [open, cart]);

  const handleQuantityChange = (key, change) => {
    setQuantities(prev => {
      const current = prev[key] || 0;
      const next = Math.max(0, current + change);
      return { ...prev, [key]: next };
    });
  };

  // Group items by subcategory for organized display
  const groupedItems = useMemo(() => {
    return items.reduce((acc, item) => {
      const subcat = item.customizeSubcategory || 'General';
      if (!acc[subcat]) acc[subcat] = [];
      acc[subcat].push(item);
      return acc;
    }, {});
  }, [items]);

  // Dynamic calculations
  const grandTotal = useMemo(() => {
    return items.reduce((sum, item) => {
      const isVariantItem = item.hasStainRemoval || item.stainRemovalPrice > 0 || ['T-Shirt', 'Shirt', 'Pant'].includes(item.name);
      if (isVariantItem) {
        const qtyNormal = quantities[`${item.id}-normal`] || 0;
        const qtyStain = quantities[`${item.id}-stain`] || 0;
        const priceNormal = Number(item.price) || 90;
        const priceStain = Number(item.stainRemovalPrice) || 130;
        return sum + (qtyNormal * priceNormal) + (qtyStain * priceStain);
      } else {
        const qty = quantities[item.id] || 0;
        return sum + (Number(item.price) || 0) * qty;
      }
    }, 0);
  }, [items, quantities]);

  const totalSelectedCount = useMemo(() => {
    return Object.values(quantities).reduce((sum, q) => sum + q, 0);
  }, [quantities]);

  const formatUnitLabel = (unit) => {
    if (!unit) return 'Per Piece';
    const u = unit.toLowerCase();
    if (u === 'sq ft' || u === 'sqft') return 'Per Sq. Ft.';
    if (u === 'set') return 'Per Set';
    if (u === 'carpet') return 'Per Carpet';
    if (u === 'pair') return 'Per Pair';
    return 'Per Piece';
  };

  // Handle Add to Cart action
  const handleAddToCart = () => {
    if (totalSelectedCount === 0) {
      setToast('Please select at least 1 item quantity.');
      setTimeout(() => setToast(''), 2500);
      return;
    }

    items.forEach(item => {
      const isVariantItem = item.hasStainRemoval || item.stainRemovalPrice > 0 || ['T-Shirt', 'Shirt', 'Pant'].includes(item.name);

      if (isVariantItem) {
        const qtyNormal = quantities[`${item.id}-normal`] || 0;
        const qtyStain = quantities[`${item.id}-stain`] || 0;

        const normalName = `${item.name} - Normal Dry Cleaning`;
        const stainName = `${item.name} - Dry Cleaning + Stain Removal`;

        const normalPrice = Number(item.price) || 90;
        const stainPrice = Number(item.stainRemovalPrice) || 130;
        const unitLabel = formatUnitLabel(item.unit);

        onUpdateQuantity(normalName, qtyNormal, normalPrice, unitLabel);
        onUpdateQuantity(stainName, qtyStain, stainPrice, unitLabel);
      } else {
        const selectedQty = quantities[item.id] || 0;
        onUpdateQuantity(
          item.name,
          selectedQty,
          item.price,
          formatUnitLabel(item.unit)
        );
      }
    });

    setToast(`Added Dry Cleaning selections to cart! (₹${grandTotal})`);
    setTimeout(() => {
      setToast('');
      onClose();
    }, 1200);
  };

  if (!open) return null;

  return (
    <>
      {toast && (
        <div className="toast-message" style={{ position: 'fixed', top: 20, right: 20, zIndex: 10000, background: '#10b981', color: '#fff', padding: '12px 20px', borderRadius: 8, fontWeight: 700, boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
          {toast}
        </div>
      )}

      <div className="sidebar-overlay" onClick={onClose} style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', zIndex: 9998 }} />

      <div className="custom-sidebar dryclean-modal-panel">
        <div className="dryclean-header">
          <div>
            <h2>Dry Cleaning</h2>
            <p>Select your items and quantities below</p>
          </div>
          <button onClick={onClose} aria-label="Close modal">✕</button>
        </div>

        <div className="dryclean-body">
          {loading ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              Loading Dry Cleaning price list…
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#ef4444', fontWeight: 600 }}>
              {error}
            </div>
          ) : items.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              No active Dry Cleaning items available.
            </div>
          ) : (
            Object.entries(groupedItems).map(([subcategory, subItems]) => (
              <div key={subcategory} style={{ marginBottom: 24 }}>
                <h3 className="dryclean-category-title">
                  {subcategory}
                </h3>

                {subItems.map(item => {
                  const isVariantItem = item.hasStainRemoval || item.stainRemovalPrice > 0 || ['T-Shirt', 'Shirt', 'Pant'].includes(item.name);

                  if (isVariantItem) {
                    const qtyNormal = quantities[`${item.id}-normal`] || 0;
                    const qtyStain = quantities[`${item.id}-stain`] || 0;
                    const priceNormal = Number(item.price) || 90;
                    const priceStain = Number(item.stainRemovalPrice) || 130;
                    const hasSelected = qtyNormal > 0 || qtyStain > 0;

                    return (
                      <div
                        key={item.id}
                        className={`dryclean-item-card ${hasSelected ? 'has-selected' : ''}`}
                      >
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                          <div>
                            <strong className="dryclean-item-name">{item.name}</strong>
                            <span className="dryclean-unit-label">{formatUnitLabel(item.unit)}</span>
                          </div>
                        </div>

                        {/* Separate Independent Variant Row 1: Normal Dry Cleaning */}
                        <div className="dryclean-variant-row">
                          <div className="dryclean-variant-info">
                            <span className="variant-title">Normal Dry Cleaning</span>
                            <span className="variant-price">₹{priceNormal} <small>/ {formatUnitLabel(item.unit)}</small></span>
                          </div>
                          <div className="dryclean-qty-controls">
                            <button
                              type="button"
                              className="dryclean-qty-btn qty-minus"
                              onClick={() => handleQuantityChange(`${item.id}-normal`, -1)}
                              disabled={qtyNormal === 0}
                              aria-label="Decrease normal dry cleaning quantity"
                            >
                              −
                            </button>
                            <span className="dryclean-qty-count">{qtyNormal}</span>
                            <button
                              type="button"
                              className="dryclean-qty-btn qty-plus"
                              onClick={() => handleQuantityChange(`${item.id}-normal`, 1)}
                              aria-label="Increase normal dry cleaning quantity"
                            >
                              +
                            </button>
                          </div>
                        </div>

                        {/* Separate Independent Variant Row 2: Dry Cleaning + Stain Removal */}
                        <div className="dryclean-variant-row">
                          <div className="dryclean-variant-info">
                            <span className="variant-title">Dry Cleaning + Stain Removal</span>
                            <span className="variant-price">₹{priceStain} <small>/ {formatUnitLabel(item.unit)}</small></span>
                          </div>
                          <div className="dryclean-qty-controls">
                            <button
                              type="button"
                              className="dryclean-qty-btn qty-minus"
                              onClick={() => handleQuantityChange(`${item.id}-stain`, -1)}
                              disabled={qtyStain === 0}
                              aria-label="Decrease stain removal dry cleaning quantity"
                            >
                              −
                            </button>
                            <span className="dryclean-qty-count">{qtyStain}</span>
                            <button
                              type="button"
                              className="dryclean-qty-btn qty-plus"
                              onClick={() => handleQuantityChange(`${item.id}-stain`, 1)}
                              aria-label="Increase stain removal dry cleaning quantity"
                            >
                              +
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  }

                  // Standard Item (No variants)
                  const qty = quantities[item.id] || 0;
                  const itemSubtotal = (Number(item.price) || 0) * qty;

                  return (
                    <div
                      key={item.id}
                      className={`dryclean-item-card ${qty > 0 ? 'has-selected' : ''}`}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <div>
                          <strong className="dryclean-item-name">{item.name}</strong>
                          <span className="dryclean-unit-label">
                            ₹{item.price} / {formatUnitLabel(item.unit)}
                          </span>
                        </div>

                        <div className="dryclean-qty-controls">
                          <button
                            type="button"
                            className="dryclean-qty-btn qty-minus"
                            onClick={() => handleQuantityChange(item.id, -1)}
                            disabled={qty === 0}
                            aria-label="Decrease quantity"
                          >
                            −
                          </button>
                          <span className="dryclean-qty-count">{qty}</span>
                          <button
                            type="button"
                            className="dryclean-qty-btn qty-plus"
                            onClick={() => handleQuantityChange(item.id, 1)}
                            aria-label="Increase quantity"
                          >
                            +
                          </button>
                        </div>
                      </div>

                      {qty > 0 && (
                        <div style={{ marginTop: 8, fontSize: '0.82rem', color: '#27187E', fontWeight: 700, textAlign: 'right' }}>
                          Subtotal: ₹{itemSubtotal}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            ))
          )}
        </div>

        <div className="dryclean-footer">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <span style={{ fontSize: '0.88rem', color: '#475569', fontWeight: 600 }}>
              Items Selected: <strong style={{ color: '#0f172a' }}>{totalSelectedCount}</strong>
            </span>
            <span style={{ fontSize: '1.25rem', fontWeight: 800, color: '#27187E' }}>
              Total: ₹{grandTotal}
            </span>
          </div>

          <button
            onClick={handleAddToCart}
            disabled={totalSelectedCount === 0}
            className="dryclean-submit-btn"
          >
            Add Selected Items to Cart
          </button>
        </div>
      </div>
    </>
  );
}
