import React from "react";
import Pricing from "../components/Pricing";
import CustomizeSidebar from "../components/CustomizeSidebar";
import DryCleaningModal from "../components/DryCleaningModal";
import ShoeCleaningModal from "../components/ShoeCleaningModal";
import Cart from "../components/Cart";
import CheckoutModal from "../components/CheckoutModal";

export default function ServicesPage({
  cart,
  onUpdateQuantity,
  isCustomizeOpen,
  onOpenCustomize,
  onCloseCustomize,
  isDryCleanOpen,
  onOpenDryClean,
  onCloseDryClean,
  isShoeCleanOpen,
  onOpenShoeClean,
  onCloseShoeClean,
  onRemoveItem,
  onOpenCheckout,
  isCheckoutOpen,
  onCloseCheckout
}) {
  return (
    <>
      <Pricing
        cart={cart}
        onUpdateQuantity={onUpdateQuantity}
        onCustomize={onOpenCustomize}
        onOpenDryClean={onOpenDryClean}
        onOpenShoeClean={onOpenShoeClean}
      />
      <DryCleaningModal
        open={isDryCleanOpen}
        onClose={onCloseDryClean}
        cart={cart}
        onUpdateQuantity={onUpdateQuantity}
      />
      <ShoeCleaningModal
        open={isShoeCleanOpen}
        onClose={onCloseShoeClean}
        cart={cart}
        onUpdateQuantity={onUpdateQuantity}
      />
      <CustomizeSidebar
        isOpen={isCustomizeOpen}
        onClose={onCloseCustomize}
        onUpdateQuantity={onUpdateQuantity}
        cart={cart}
      />

      <Cart
        cart={cart}
        onUpdateQuantity={onUpdateQuantity}
        onRemoveItem={onRemoveItem}
        onCheckout={onOpenCheckout}
      />

      <CheckoutModal open={isCheckoutOpen} cart={cart} onClose={onCloseCheckout} />
    </>
  );
}

