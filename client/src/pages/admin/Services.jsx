import React, { useEffect, useState } from 'react';
import API from '../../api/api';

const emptyService = {
  id: '',
  name: '',
  unit: '',
  price: 0,
  surahiUnitCost: 0,
  features: '',
  featured: false,
  displayType: 'main',
  customizeCategory: '',
  customizeSubcategory: '',
  isActive: true,
  sortOrder: 0
};

export default function AdminServices() {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [form, setForm] = useState(emptyService);
  const [isEditing, setIsEditing] = useState(false);
  const [activeTab, setActiveTab] = useState('all'); // 'all' | 'main' | 'customize'

  const fetchServices = async () => {
    setLoading(true);
    try {
      const response = await API.get('/api/services', {
        params: { includeInactive: true }
      });
      setServices(response.data || []);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to load services');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchServices();
  }, []);

  const [successMessage, setSuccessMessage] = useState('');

  const resetForm = () => {
    setForm(emptyService);
    setIsEditing(false);
  };

  const showNotification = (msg) => {
    setSuccessMessage(msg);
    setTimeout(() => setSuccessMessage(''), 3000);
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError(null);
    try {
      const targetId = form.id || form._id;
      if (isEditing) {
        const response = await API.put(`/api/services/${encodeURIComponent(targetId)}`, {
          name: form.name,
          unit: form.unit,
          price: Number(form.price),
          surahiUnitCost: Number(form.surahiUnitCost || 0),
          features: typeof form.features === 'string'
            ? form.features.split(',').map((item) => item.trim()).filter(Boolean)
            : form.features,
          featured: form.featured,
          displayType: form.displayType,
          customizeCategory: form.customizeCategory,
          customizeSubcategory: form.customizeSubcategory,
          isActive: Boolean(form.isActive),
          sortOrder: Number(form.sortOrder || 0)
        });
        setServices((prev) => prev.map((service) => (
          (service.id && service.id === targetId) || service._id === targetId ? response.data : service
        )));
        showNotification(`Service "${response.data.name}" updated successfully!`);
      } else {
        const response = await API.post('/api/services', {
          id: form.id,
          name: form.name,
          unit: form.unit,
          price: Number(form.price),
          surahiUnitCost: Number(form.surahiUnitCost || 0),
          features: typeof form.features === 'string'
            ? form.features.split(',').map((item) => item.trim()).filter(Boolean)
            : form.features,
          featured: form.featured,
          displayType: form.displayType,
          customizeCategory: form.customizeCategory,
          customizeSubcategory: form.customizeSubcategory,
          isActive: Boolean(form.isActive),
          sortOrder: Number(form.sortOrder || 0)
        });
        setServices((prev) => [response.data, ...prev]);
        showNotification(`New service "${response.data.name}" created successfully!`);
      }
      resetForm();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to save service');
    }
  };

  const handleEdit = (service) => {
    setForm({
      ...service,
      id: service.id || service._id,
      features: (service.features || []).join(', '),
      isActive: service.isActive !== false,
      sortOrder: service.sortOrder || 0
    });
    setIsEditing(true);
    setError(null);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleToggleActive = async (service) => {
    try {
      const targetId = service.id || service._id;
      const nextActive = service.isActive === false; // toggle
      const response = await API.put(`/api/services/${encodeURIComponent(targetId)}`, {
        isActive: nextActive
      });
      setServices((prev) => prev.map((s) => (
        (s.id && s.id === targetId) || s._id === targetId ? response.data : s
      )));
      showNotification(`Service "${response.data.name}" ${nextActive ? 'enabled' : 'disabled'}!`);
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to update status');
    }
  };

  const handleDelete = async (service) => {
    try {
      const targetId = typeof service === 'string' ? service : (service.id || service._id);
      const serviceName = typeof service === 'string' ? service : (service.name || targetId);
      const confirmed = window.confirm(`Are you sure you want to remove "${serviceName}"? This will hide/remove the service record.`);
      if (!confirmed) return;

      await API.delete(`/api/services/${encodeURIComponent(targetId)}`);
      showNotification(`Service "${serviceName}" removed successfully.`);
      fetchServices();
    } catch (err) {
      setError(err?.response?.data?.message || err.message || 'Unable to delete service');
    }
  };

  const filteredServices = services.filter((s) => {
    if (activeTab === 'main') return (s.displayType || 'main') === 'main';
    if (activeTab === 'customize') return s.displayType === 'customize';
    return true;
  });

  if (loading) {
    return <div className="admin-empty-state">Loading services…</div>;
  }

  return (
    <div className="admin-section">
      {error && (
        <div className="admin-card" style={{ background: '#fef2f2', border: '1px solid #fca5a5', color: '#991b1b', marginBottom: 15, padding: '12px 16px', borderRadius: 8 }}>
          <strong>Error:</strong> {error}
        </div>
      )}

      {successMessage && (
        <div className="admin-card" style={{ background: '#f0fdf4', border: '1px solid #86efac', color: '#166534', marginBottom: 15, padding: '12px 16px', borderRadius: 8 }}>
          ✓ {successMessage}
        </div>
      )}
      <div className="admin-card" style={{ marginBottom: 20 }}>
        <div className="admin-card__title">{isEditing ? 'Edit Service Option' : 'Add New Service Option'}</div>
        <form className="admin-form" onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          <div className="admin-form-grid">
            <div className="admin-form-group">
              <label className="admin-form-label">Service ID</label>
              <input
                className="admin-input"
                placeholder="e.g. dryclean-shirt-tshirt"
                value={form.id}
                onChange={(event) => setForm({ ...form, id: event.target.value })}
                required
                disabled={isEditing}
              />
            </div>
            
            <div className="admin-form-group">
              <label className="admin-form-label">Service Name</label>
              <input
                className="admin-input"
                placeholder="e.g. Shirt/T-Shirt"
                value={form.name}
                onChange={(event) => setForm({ ...form, name: event.target.value })}
                required
              />
            </div>

            <div className="admin-form-group">
              <label className="admin-form-label">Unit of Measure</label>
              <input
                className="admin-input"
                placeholder="e.g. item, pair, kg, sq ft"
                value={form.unit}
                onChange={(event) => setForm({ ...form, unit: event.target.value })}
                required
              />
            </div>

            <div className="admin-form-group">
              <label className="admin-form-label">Price (₹)</label>
              <input
                className="admin-input"
                type="number"
                placeholder="e.g. 39"
                value={form.price}
                onChange={(event) => setForm({ ...form, price: event.target.value })}
                required
              />
            </div>

            <div className="admin-form-group">
              <label className="admin-form-label">Surahi Unit Cost (₹)</label>
              <input
                className="admin-input"
                type="number"
                placeholder="e.g. 20 (Outsourced Cost)"
                value={form.surahiUnitCost || ''}
                onChange={(event) => setForm({ ...form, surahiUnitCost: event.target.value })}
              />
            </div>

            <div className="admin-form-group">
              <label className="admin-form-label">Catalog Category Type</label>
              <select
                className="admin-select"
                value={form.displayType}
                onChange={(event) => setForm({ ...form, displayType: event.target.value })}
              >
                <option value="main">Main Catalog Service</option>
                <option value="customize">Customize Add-on Option</option>
              </select>
            </div>

            {form.displayType === 'customize' && (
              <>
                <div className="admin-form-group">
                  <label className="admin-form-label">Customize Category</label>
                  <input
                    className="admin-input"
                    placeholder="e.g. Dry Clean, Bed Set Clean, Shoe Cleaning"
                    value={form.customizeCategory}
                    onChange={(event) => setForm({ ...form, customizeCategory: event.target.value })}
                  />
                </div>
                <div className="admin-form-group">
                  <label className="admin-form-label">Customize Subcategory</label>
                  <input
                    className="admin-input"
                    placeholder="e.g. Men's Wear, Women's Wear, Others"
                    value={form.customizeSubcategory}
                    onChange={(event) => setForm({ ...form, customizeSubcategory: event.target.value })}
                  />
                </div>
              </>
            )}

            <div className="admin-form-group">
              <label className="admin-form-label">Sort Order</label>
              <input
                className="admin-input"
                type="number"
                placeholder="e.g. 1, 2, 10"
                value={form.sortOrder}
                onChange={(event) => setForm({ ...form, sortOrder: event.target.value })}
              />
            </div>

            <div className="admin-form-group">
              <label className="admin-form-label">Features (comma-separated)</label>
              <input
                className="admin-input"
                placeholder="e.g. Gentle wash, Stain removal"
                value={form.features}
                onChange={(event) => setForm({ ...form, features: event.target.value })}
              />
            </div>
          </div>

          <div className="admin-form-row" style={{ justifyContent: 'space-between', flexWrap: 'wrap', gap: 15 }}>
            <div style={{ display: 'flex', gap: 20, alignItems: 'center' }}>
              <label style={{ display: 'inline-flex', alignItems: 'center', gap: 10, cursor: 'pointer', fontSize: '0.88rem', fontWeight: 600, color: '#334155' }}>
                <input
                  type="checkbox"
                  checked={form.isActive}
                  onChange={(event) => setForm({ ...form, isActive: event.target.checked })}
                  style={{ width: '16px', height: '16px', cursor: 'pointer' }}
                />
                Active (Visible to Customers)
              </label>

              <label style={{ display: 'inline-flex', alignItems: 'center', gap: 10, cursor: 'pointer', fontSize: '0.88rem', fontWeight: 600, color: '#334155' }}>
                <input
                  type="checkbox"
                  checked={form.featured}
                  onChange={(event) => setForm({ ...form, featured: event.target.checked })}
                  style={{ width: '16px', height: '16px', cursor: 'pointer' }}
                />
                Featured Service
              </label>
            </div>

            <div style={{ display: 'flex', gap: 12 }}>
              {isEditing && (
                <button type="button" className="admin-button admin-button--secondary" onClick={resetForm}>
                  Cancel
                </button>
              )}
              <button type="submit" className="admin-button">
                {isEditing ? 'Update Option' : 'Create Option'}
              </button>
            </div>
          </div>
        </form>
      </div>

      <div className="admin-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 12, marginBottom: 16 }}>
          <div className="admin-card__title" style={{ margin: 0 }}>Service Catalog & Customize Options</div>
          
          <div style={{ display: 'flex', gap: 6, background: '#f1f5f9', padding: '4px', borderRadius: '8px' }}>
            <button
              onClick={() => setActiveTab('all')}
              style={{
                border: 'none',
                padding: '6px 14px',
                borderRadius: '6px',
                cursor: 'pointer',
                fontSize: '0.78rem',
                fontWeight: 700,
                background: activeTab === 'all' ? '#ffffff' : 'transparent',
                color: activeTab === 'all' ? '#0f172a' : '#64748b',
                boxShadow: activeTab === 'all' ? '0 1px 2px rgba(0,0,0,0.08)' : 'none'
              }}
            >
              All ({services.length})
            </button>
            <button
              onClick={() => setActiveTab('main')}
              style={{
                border: 'none',
                padding: '6px 14px',
                borderRadius: '6px',
                cursor: 'pointer',
                fontSize: '0.78rem',
                fontWeight: 700,
                background: activeTab === 'main' ? '#ffffff' : 'transparent',
                color: activeTab === 'main' ? '#0f172a' : '#64748b',
                boxShadow: activeTab === 'main' ? '0 1px 2px rgba(0,0,0,0.08)' : 'none'
              }}
            >
              Main Services ({services.filter(s => (s.displayType || 'main') === 'main').length})
            </button>
            <button
              onClick={() => setActiveTab('customize')}
              style={{
                border: 'none',
                padding: '6px 14px',
                borderRadius: '6px',
                cursor: 'pointer',
                fontSize: '0.78rem',
                fontWeight: 700,
                background: activeTab === 'customize' ? '#ffffff' : 'transparent',
                color: activeTab === 'customize' ? '#0f172a' : '#64748b',
                boxShadow: activeTab === 'customize' ? '0 1px 2px rgba(0,0,0,0.08)' : 'none'
              }}
            >
              Customize Add-ons ({services.filter(s => s.displayType === 'customize').length})
            </button>
          </div>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Unit</th>
                <th>Price</th>
                <th>Surahi Cost</th>
                <th>Display</th>
                <th>Category</th>
                <th>Subcategory</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredServices.map((service) => {
                const isActive = service.isActive !== false;
                return (
                  <tr key={service._id} style={{ opacity: isActive ? 1 : 0.6 }}>
                    <td><code style={{ fontSize: '0.75rem' }}>{service.id}</code></td>
                    <td style={{ fontWeight: 'bold' }}>{service.name}</td>
                    <td>{service.unit}</td>
                    <td style={{ fontWeight: 'bold' }}>₹{service.price}</td>
                    <td>{service.surahiUnitCost ? `₹${service.surahiUnitCost}` : '—'}</td>
                    <td>
                      <span className={`admin-badge ${service.displayType === 'customize' ? 'admin-badge--info' : 'admin-badge--primary'}`}>
                        {service.displayType === 'customize' ? 'Customize Add-on' : 'Main Catalog'}
                      </span>
                    </td>
                    <td>{service.customizeCategory || '-'}</td>
                    <td>{service.customizeSubcategory || '-'}</td>
                    <td>
                      <span className={`admin-badge ${isActive ? 'admin-badge--success' : 'admin-badge--warning'}`}>
                        {isActive ? 'Active' : 'Disabled'}
                      </span>
                    </td>
                    <td style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                      <button type="button" className="admin-button" onClick={() => handleEdit(service)}>
                        Edit
                      </button>
                      <button
                        type="button"
                        className="admin-button"
                        onClick={() => handleToggleActive(service)}
                        style={{ background: isActive ? '#f59e0b' : '#10b981', color: '#fff' }}
                      >
                        {isActive ? 'Disable' : 'Enable'}
                      </button>
                      <button type="button" className="admin-button" onClick={() => handleDelete(service)} style={{ background: '#ef4444', color: '#fff' }}>
                        Delete
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
