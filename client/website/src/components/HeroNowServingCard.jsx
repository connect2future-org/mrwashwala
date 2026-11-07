import React from "react";

export default function HeroNowServingCard({ onExplore }) {
  const handleExplore = () => {
    if (typeof onExplore === "function") {
      onExplore();
      return;
    }

    const branchSection = document.getElementById("branches-section");
    if (branchSection) {
      branchSection.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  };

  return (
    <aside className="hero-now-serving-card" aria-label="Now serving from three locations in Mysuru">
      <div className="hero-now-serving-head">NOW SERVING FROM</div>
      <div className="hero-now-serving-title">3 LOCATIONS IN MYSURU</div>

      <ul className="hero-now-serving-list">
        <li>
          <span className="hero-now-serving-icon" aria-hidden="true">
            📍
          </span>
          <span>Vijayanagar 2nd Stage</span>
        </li>
        <li>
          <span className="hero-now-serving-icon" aria-hidden="true">
            📍
          </span>
          <span>Vijayanagar 4th Stage</span>
        </li>
        <li className="hero-new-branch-item">
          <div className="hero-now-serving-badge-row">
            <span className="hero-now-serving-icon" aria-hidden="true">
              ✨
            </span>
            <span className="hero-now-serving-new-tag">Newly Opened</span>
          </div>
          <div className="hero-now-serving-outlet-row">
            <span className="hero-now-serving-icon" aria-hidden="true">
              📍
            </span>
            <span className="hero-now-serving-new-name">Bogadi</span>
          </div>
        </li>
      </ul>

      <button type="button" className="hero-now-serving-explore" onClick={handleExplore}>
        Explore <span aria-hidden="true">→</span>
      </button>
    </aside>
  );
}
