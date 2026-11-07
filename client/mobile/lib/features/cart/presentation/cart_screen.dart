import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../checkout/presentation/checkout_screen.dart';
import 'cart_controller.dart';

class CartScreen extends StatelessWidget {
  final CartController cartController;
  final AuthController? authController;
  final VoidCallback? onBrowseServices;

  const CartScreen({
    super.key,
    required this.cartController,
    this.authController,
    this.onBrowseServices,
  });

  LaundryIllustrationType _getIllustrationForCartItem(CartItemModel item) {
    final name = item.name.toLowerCase();
    if (name.contains('t-shirt') || name.contains('tshirt')) {
      return LaundryIllustrationType.tshirt;
    } else if (name.contains('shirt') || name.contains('suit') || name.contains('blazer') || name.contains('saree')) {
      return LaundryIllustrationType.shirtOnHanger;
    } else if (name.contains('jean') || name.contains('pant') || name.contains('trouser')) {
      return LaundryIllustrationType.jeans;
    } else if (name.contains('shoe') || name.contains('sneaker')) {
      return LaundryIllustrationType.sneakers;
    } else if (name.contains('iron') || name.contains('press')) {
      return LaundryIllustrationType.iron;
    } else if (name.contains('towel')) {
      return LaundryIllustrationType.foldedTowels;
    }
    return LaundryIllustrationType.laundryBasket;
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear Cart?',
          style: AppTypography.sans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: AppTypography.sans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTypography.sans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cartController.clearCart();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Clear All',
              style: AppTypography.sans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cartController,
      builder: (context, _) {
        final isEmpty = cartController.isEmpty;
        final totalItems = cartController.totalQuantity;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Cart',
                  style: AppTypography.sans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isEmpty
                      ? 'Review your laundry order'
                      : '$totalItems item${totalItems > 1 ? 's' : ''} selected',
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              if (!isEmpty)
                TextButton(
                  onPressed: () => _showClearCartDialog(context),
                  child: Text(
                    'Clear',
                    style: AppTypography.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
            ],
          ),
          body: isEmpty
              ? _buildEmptyCart(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          // Cart Items
                          ...cartController.items.map((item) => _buildCartItemCard(context, item)),

                          const SizedBox(height: 16),

                          // Bill Summary Card
                          _buildBillSummary(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Sticky Checkout Bottom Bar
                    _buildCheckoutBar(context),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
    final illustrationType = _getIllustrationForCartItem(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sketch Illustration
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.cobaltLight.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: LaundryIllustration(
                    type: illustrationType,
                    size: 42,
                    strokeColor: AppColors.cobaltBlue,
                    strokeWidth: 1.8,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${item.price.toStringAsFixed(0)} / ${item.unit}',
                      style: AppTypography.sans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (item.stainRemoval || item.premiumClean) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (item.stainRemoval)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cobaltLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+ Stain Removal',
                                style: AppTypography.sans(fontSize: 10, color: AppColors.cobaltBlue),
                              ),
                            ),
                          if (item.premiumClean)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cobaltLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+ Premium Clean',
                                style: AppTypography.sans(fontSize: 10, color: AppColors.cobaltBlue),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Line Total
              Text(
                '₹${item.lineTotal.toStringAsFixed(0)}',
                style: AppTypography.sans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),

          // Stepper & Delete Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 20),
                onPressed: () {
                  final removedName = item.name;
                  cartController.removeItem(item.serviceId);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$removedName removed from cart'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.textPrimary,
                    ),
                  );
                },
              ),

              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => cartController.decrementQuantity(item.serviceId),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Icon(Icons.remove_rounded, size: 16, color: AppColors.textPrimary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => cartController.incrementQuantity(item.serviceId),
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Icon(Icons.add_rounded, size: 16, color: AppColors.cobaltBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary() {
    return SketchCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: AppTypography.sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', '₹${cartController.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Estimated Total', '₹${cartController.subtotal.toStringAsFixed(0)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.sans(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.sans(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? AppColors.cobaltBlue : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Amount',
                style: AppTypography.sans(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '₹${cartController.subtotal.toStringAsFixed(0)}',
                style: AppTypography.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cobaltBlue,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: CobaltButton(
              text: 'Proceed to Checkout',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(
                      cartController: cartController,
                      authController: authController ?? AuthController(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.cobaltLight.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: LaundryIllustration(
                  type: LaundryIllustrationType.laundryBasket,
                  size: 90,
                  strokeColor: AppColors.cobaltBlue,
                  strokeWidth: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: AppTypography.sans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from our service categories to get started.',
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            CobaltButton(
              text: 'Browse Services',
              width: 200,
              onPressed: onBrowseServices,
            ),
          ],
        ),
      ),
    );
  }
}
