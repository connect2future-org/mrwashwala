import React, { useEffect, useState, useMemo } from 'react';
import API from '../api/api';

export default function ShoeCleaningModal({
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

  // Fetch active Shoe Cleaning items from backend database
  useEffect(() => {
    if (!open) return;

    const fetchShoeCleaningItems = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await API.get('/api/services', {
          params: { displayType: 'customize', customizeCategory: 'Shoe Cleaning' }
        });
        
        let fetchedList = response.data || [];

        // Sort items by sortOrder
        fetchedList.sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
        setItems(fetchedList);

        // Sync local quantities with current cart
        const initialQtyMap = {};

        fetchedList.forEach(item => {
          const normalName = `${item.name} - Normal Clean`;
          const premiumName = `${item.name} - Premium Clean`;

          const normalCart = cart.find(c => c.name === normalName);
          const premiumCart = cart.find(c => c.name === premiumName);

          initialQtyMap[`${item.id}-normal`] = normalCart ? normalCart.quantity : 0;
          initialQtyMap[`${item.id}-premium`] = premiumCart ? premiumCart.quantity : 0;
        });

        setQuantities(initialQtyMap);
      } catch (err) {
        console.error('Failed to load Shoe Cleaning items:', err);
        setError('Unable to load Shoe Cleaning options right now. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    fetchShoeCleaningItems();
  }, [open, cart]);

  const handleQuantityChange = (key, change) => {
    setQuantities(prev => {
      const current = prev[key] || 0;
      const next = Math.max(0, current + change);
      return { ...prev, [key]: next };
    });
  };

  // Dynamic calculations
  const grandTotal = useMemo(() => {
    return items.reduce((sum, item) => {
      const qtyNormal = quantities[`${item.id}-normal`] || 0;
      const qtyPremium = quantities[`${item.id}-premium`] || 0;
      const priceNormal = Number(item.price) || 159;
      const pricePremium = Number(item.premiumCleanPrice) || 220;
      return sum + (qtyNormal * priceNormal) + (qtyPremium * pricePremium);
    }, 0);
  }, [items, quantities]);

  const totalSelectedCount = useMemo(() => {
    return Object.values(quantities).reduce((sum, q) => sum + q, 0);
  }, [quantities]);

  const formatUnitLabel = (unit) => {
    if (!unit) return 'Per Pair';
    const u = unit.toLowerCase();
    if (u === 'pair') return 'Per Pair';
    return 'Per Pair';
  };

  // Handle Add to Cart action
  const handleAddToCart = () => {
    if (totalSelectedCount === 0) {
      setToast('Please select at least 1 shoe cleaning option quantity.');
      setTimeout(() => setToast(''), 2500);
      return;
    }

    items.forEach(item => {
      const qtyNormal = quantities[`${item.id}-normal`] || 0;
      const qtyPremium = quantities[`${item.id}-premium`] || 0;

      const normalName = `${item.name} - Normal Clean`;
      const premiumName = `${item.name} - Premium Clean`;

      const normalPrice = Number(item.price) || 159;
      const premiumPrice = Number(item.premiumCleanPrice) || 220;
      const unitLabel = formatUnitLabel(item.unit);

      onUpdateQuantity(normalName, qtyNormal, normalPrice, unitLabel);
      onUpdateQuantity(premiumName, qtyPremium, premiumPrice, unitLabel);
    });

    setToast(`Added Shoe Cleaning selections to cart! (₹${grandTotal})`);
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

      <div className="custom-sidebar shoeclean-modal-panel">
        <div className="shoeclean-header">
          <div>
            <h2>Shoe Cleaning</h2>
            <p>Select your shoe type and cleaning option below</p>
          </div>
          <button onClick={onClose} aria-label="Close modal">✕</button>
        </div>

        <div className="shoeclean-body">
          {loading ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              Loading Shoe Cleaning options…
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#ef4444', fontWeight: 600 }}>
              {error}
            </div>
          ) : items.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              No active Shoe Cleaning options available.
            </div>
          ) : (
            items.map(item => {
              const qtyNormal = quantities[`${item.id}-normal`] || 0;
              const qtyPremium = quantities[`${item.id}-premium`] || 0;
              const priceNormal = Number(item.price) || 159;
              const pricePremium = Number(item.premiumCleanPrice) || 220;
              const hasSelected = qtyNormal > 0 || qtyPremium > 0;

              return (
                <div
                  key={item.id}
                  className={`shoeclean-item-card ${hasSelected ? 'has-selected' : ''}`}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
                    <div>
                      <strong className="shoeclean-item-name">{item.name}</strong>
                      <span className="shoeclean-unit-label">{formatUnitLabel(item.unit)}</span>
                    </div>
                  </div>

                  {/* Option 1: Normal Clean */}
                  <div className="shoeclean-variant-row">
                    <div className="shoeclean-variant-info">
                      <span className="variant-title">Normal Clean</span>
                      <span className="variant-price">₹{priceNormal} <small>/ {formatUnitLabel(item.unit)}</small></span>
                    </div>
                    <div className="shoeclean-qty-controls">
                      <button
                        type="button"
                        className="shoeclean-qty-btn qty-minus"
                        onClick={() => handleQuantityChange(`${item.id}-normal`, -1)}
                        disabled={qtyNormal === 0}
                        aria-label="Decrease normal clean quantity"
                      >
                        −
                      </button>
                      <span className="shoeclean-qty-count">{qtyNormal}</span>
                      <button
                        type="button"
                        className="shoeclean-qty-btn qty-plus"
                        onClick={() => handleQuantityChange(`${item.id}-normal`, 1)}
                        aria-label="Increase normal clean quantity"
                      >
                        +
                      </button>
                    </div>
                  </div>

                  {/* Option 2: Premium Clean */}
                  <div className="shoeclean-variant-row">
                    <div className="shoeclean-variant-info">
                      <span className="variant-title">Premium Clean</span>
                      <span className="variant-price">₹{pricePremium} <small>/ {formatUnitLabel(item.unit)}</small></span>
                    </div>
                    <div className="shoeclean-qty-controls">
                      <button
                        type="button"
                        className="shoeclean-qty-btn qty-minus"
                        onClick={() => handleQuantityChange(`${item.id}-premium`, -1)}
                        disabled={qtyPremium === 0}
                        aria-label="Decrease premium clean quantity"
                      >
                        −
                      </button>
                      <span className="shoeclean-qty-count">{qtyPremium}</span>
                      <button
                        type="button"
                        className="shoeclean-qty-btn qty-plus"
                        onClick={() => handleQuantityChange(`${item.id}-premium`, 1)}
                        aria-label="Increase premium clean quantity"
                      >
                        +
                      </button>
                    </div>
                  </div>
                </div>
              );
            })
          )}
        </div>

        <div className="shoeclean-footer">
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
            className="shoeclean-submit-btn"
          >
            Add Selected Shoes to Cart
          </button>
        </div>
      </div>
    </>
  );
}
