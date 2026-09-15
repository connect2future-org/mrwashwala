
import React, { useEffect, useState, useRef } from "react";
import API from "../api/api";

export default function Pricing({
  cart,
  onUpdateQuantity,
  onCustomize,
  onOpenDryClean,
  onOpenShoeClean
}) {
  const [servicesList, setServicesList] = useState([]);
  const pricingRef = useRef(null);
  const getServiceImage = (serviceName) => {
    const images = {
      "Wash & Fold": "/pricing/fold.jpg",
      "Wash & Iron": "/pricing/iron.jpg",
      "Shoe Cleaning": "/pricing/shoe.jpg",
      "Dry Cleaning": "/pricing/dry.jpg",
      "Customize Your Service": "/pricing/wash.jpg"
    };
    return images[serviceName] || "/pricing/fold.jpg";
  };

  useEffect(() => {
    fetchServices();
  }, []);

  const fetchServices = async () => {
    try {
      const response = await API.get("/api/services", {
        params: { displayType: "main" }
      });
      setServicesList(response.data);
    } catch (error) {
      console.error("Failed to fetch services", error);
    }
  };

  const scrollLeft = () => {
    if (pricingRef.current) {
      pricingRef.current.scrollBy({
        left: -320,
        behavior: "smooth"
      });
    }
  };

  const scrollRight = () => {
    if (pricingRef.current) {
      pricingRef.current.scrollBy({
        left: 320,
        behavior: "smooth"
      });
    }
  };

  return (
    <section className="pricing-section" id="pricing">
      <div className="container">
        <h2 className="section-title">
          Popular Services
        </h2>

        <div className="pricing-wrapper">

          <button
            className="pricing-arrow left"
            onClick={scrollLeft}
          >
            ‹
          </button>

          <div
            className="pricing-grid"
            ref={pricingRef}
          >

            {servicesList.map((service, i) => {
              const isDryClean = service.name
                .toLowerCase()
                .includes("dry");

              const isCustom = service.name
                .toLowerCase()
                .includes("customize");

              const isShoeClean = service.name
                .toLowerCase()
                .includes("shoe");

              const cartItem = cart.find(
                (item) => item.name === service.name
              );

              const quantity = cartItem
                ? cartItem.quantity
                : 0;

              const delay = i * 100;

              return (
                <div
                  key={service._id || service.id}
                  className={`pricing-card ${
                    service.featured
                      ? "featured"
                      : ""
                  }`}
                  data-aos="zoom-in"
                  data-aos-delay={delay}
                >
                  {service.featured && (
                    <div className="featured-badge">
                      Popular
                    </div>
                  )}

                  <div className="card-image">
                    <img
                      src={getServiceImage(service.name)}
                      alt={service.name}
                    />
                  </div>

                  <h3 className="pricing-title">{service.name}</h3>

                  <div className="pricing-meta-area">
                    {!isDryClean && !isCustom && !isShoeClean && (
                      <>
                        <p className="pricing-unit">
                          per {service.unit}
                        </p>
                        <p className="pricing-amount">
                          ₹{service.price}
                        </p>
                      </>
                    )}
                  </div>

                  <ul className="pricing-features">
                    {(service.features || []).map(
                      (feature, idx) => (
                        <li key={idx}>
                          ✓ {feature}
                        </li>
                      )
                    )}
                  </ul>

                  <div className="btn-container">

                    {isCustom ? (
                      <button
                        className="btn btn-primary customize-btn"
                        onClick={onCustomize}
                      >
                        Customize Your Service
                      </button>
                    ) : isDryClean ? (
                      <button
                        className="btn btn-primary add-btn"
                        onClick={onOpenDryClean}
                      >
                        Select Your Clothes
                      </button>
                    ) : isShoeClean ? (
                      <button
                        className="btn btn-primary add-btn"
                        onClick={onOpenShoeClean}
                      >
                        Select Your Shoes
                      </button>
                    ) : quantity === 0 ? (
                      <button
                        className="btn btn-primary add-btn"
                        onClick={() =>
                          onUpdateQuantity(
                            service.name,
                            1,
                            service.price,
                            service.unit
                          )
                        }
                      >
                        Add to Cart
                      </button>
                    ) : (
                      <div className="quantity-control">

                        <button
                          className="qty-decrease"
                          onClick={() =>
                            onUpdateQuantity(
                              service.name,
                              quantity - 1,
                              service.price,
                              service.unit
                            )
                          }
                        >
                          −
                        </button>

                        <span className="qty-display">
                          {quantity}
                        </span>

                        <button
                          className="qty-increase"
                          onClick={() =>
                            onUpdateQuantity(
                              service.name,
                              quantity + 1,
                              service.price,
                              service.unit
                            )
                          }
                        >
                          +
                        </button>

                      </div>
                    )}

                  </div>

                </div>
              );
            })}

          </div>

          <button
            className="pricing-arrow right"
            onClick={scrollRight}
          >
            →
          </button>

        </div>

      </div>
    </section>
  );
}
