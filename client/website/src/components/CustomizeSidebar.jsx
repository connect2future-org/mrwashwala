import React, { useEffect, useMemo, useState } from "react";
import API from "../api/api";

const CATEGORY_ORDER = [
  "Bed Sheet Washing",
  "Blanket Washing",
  "Additional Services"
];

export default function CustomizeSidebar({
  isOpen,
  onClose,
  onUpdateQuantity,
  cart = []
}) {
  const [toast, setToast] = useState("");
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!isOpen) return;

    const fetchCustomizeServices = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await API.get('/api/services', {
          params: { displayType: 'customize' }
        });
        
        const fetched = response.data || [];
        // Filter out Dry Clean, Shoe Cleaning items, and inactive items
        const customizedItems = fetched.filter(item => 
          item.customizeCategory && 
          item.customizeCategory !== 'Dry Clean' &&
          item.customizeCategory !== 'Shoe Cleaning' &&
          item.isActive !== false
        );

        // Sort items by sortOrder
        customizedItems.sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
        setServices(customizedItems);
      } catch (err) {
        console.error('Failed to load customize services', err);
        setError('Unable to load customization options right now.');
      } finally {
        setLoading(false);
      }
    };

    fetchCustomizeServices();
  }, [isOpen]);

  const groupedServices = useMemo(() => {
    const result = {};
    
    // Initialize required category groups in fixed order
    CATEGORY_ORDER.forEach(cat => {
      result[cat] = [];
    });

    services.forEach(service => {
      const category = service.customizeCategory || 'Additional Services';
      if (!result[category]) {
        result[category] = [];
      }
      result[category].push(service);
    });

    // Remove empty category groups
    Object.keys(result).forEach(cat => {
      if (result[cat].length === 0) {
        delete result[cat];
      }
    });

    return result;
  }, [services]);

  const getCartQty = (itemName) => {
    const item = cart.find((i) => i.name === itemName);
    return item ? item.quantity : 0;
  };

  const formatUnitLabel = (unit) => {
    if (!unit) return 'Per Piece';
    const u = unit.toLowerCase();
    if (u === 'sq ft' || u === 'sqft') return 'Per Sq. Ft.';
    if (u === 'set') return 'Per Set';
    if (u === 'carpet') return 'Per Carpet';
    if (u === 'pair') return 'Per Pair';
    return 'Per Piece';
  };

  const handleQuantityChange = (itemName, price, unit, change) => {
    const currentQty = getCartQty(itemName);
    const nextQty = Math.max(0, currentQty + change);

    onUpdateQuantity(
      itemName,
      nextQty,
      price,
      formatUnitLabel(unit)
    );
  };

  // Grand total & items count for customized service items
  const totalSelectedCount = useMemo(() => {
    return services.reduce((sum, item) => sum + getCartQty(item.name), 0);
  }, [services, cart]);

  const grandTotal = useMemo(() => {
    return services.reduce((sum, item) => sum + (getCartQty(item.name) * (Number(item.price) || 0)), 0);
  }, [services, cart]);

  const handleAddToCart = () => {
    setToast(`Updated Customized Service selections! (₹${grandTotal})`);
    setTimeout(() => {
      setToast('');
      onClose();
    }, 1200);
  };

  if (!isOpen) return null;

  return (
    <>
      {toast && (
        <div className="toast-message" style={{ position: 'fixed', top: 20, right: 20, zIndex: 10000, background: '#10b981', color: '#fff', padding: '12px 20px', borderRadius: 8, fontWeight: 700, boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
          {toast}
        </div>
      )}

      <div
        className="sidebar-overlay"
        onClick={onClose}
        style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', zIndex: 9998 }}
      />

      <div className="custom-sidebar dryclean-modal-panel">
        <div className="dryclean-header">
          <div>
            <h2>Customize Service</h2>
            <p>Select your custom service items and quantities below</p>
          </div>
          <button onClick={onClose} aria-label="Close modal">
            ✕
          </button>
        </div>

        <div className="dryclean-body">
          {loading ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              Loading customization options…
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#ef4444', fontWeight: 600 }}>
              {error}
            </div>
          ) : Object.entries(groupedServices).length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b', fontWeight: 600 }}>
              No customize services available right now.
            </div>
          ) : (
            Object.entries(groupedServices).map(([category, items]) => (
              <div key={category} style={{ marginBottom: 24 }}>
                <h3 className="dryclean-category-title">
                  {category}
                </h3>

                {items.map((item) => {
                  const qty = getCartQty(item.name);
                  const itemSubtotal = (Number(item.price) || 0) * qty;

                  return (
                    <div
                      key={item.id || item.name}
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
                            onClick={() => handleQuantityChange(item.name, item.price, item.unit, -1)}
                            disabled={qty === 0}
                            aria-label="Decrease quantity"
                          >
                            −
                          </button>
                          <span className="dryclean-qty-count">{qty}</span>
                          <button
                            type="button"
                            className="dryclean-qty-btn qty-plus"
                            onClick={() => handleQuantityChange(item.name, item.price, item.unit, 1)}
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
