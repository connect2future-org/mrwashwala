import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import '../../cart/presentation/cart_controller.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;
  final CartController? cartController;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
    this.cartController,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _quantity = 1;
  bool _stainRemoval = false;
  bool _premiumClean = false;

  double get _unitPrice {
    double total = widget.service.price;
    if (_stainRemoval && widget.service.hasStainRemoval) {
      total += widget.service.stainRemovalPrice;
    }
    if (_premiumClean && widget.service.hasPremiumClean) {
      total += widget.service.premiumCleanPrice;
    }
    return total;
  }

  double get _totalPrice => _unitPrice * _quantity;

  LaundryIllustrationType _getIllustrationForService(ServiceModel service) {
    final name = service.name.toLowerCase();
    final cat = service.customizeCategory.toLowerCase();
    if (name.contains('t-shirt') || name.contains('tshirt')) {
      return LaundryIllustrationType.tshirt;
    } else if (name.contains('shirt') || name.contains('suit') || name.contains('blazer') || cat.contains('dry clean')) {
      return LaundryIllustrationType.shirtOnHanger;
    } else if (name.contains('jean') || name.contains('pant') || name.contains('trouser')) {
      return LaundryIllustrationType.jeans;
    } else if (name.contains('shoe') || name.contains('sneaker') || cat.contains('shoe')) {
      return LaundryIllustrationType.sneakers;
    } else if (name.contains('iron') || name.contains('press') || cat.contains('iron')) {
      return LaundryIllustrationType.iron;
    } else if (name.contains('towel')) {
      return LaundryIllustrationType.foldedTowels;
    }
    return LaundryIllustrationType.laundryBasket;
  }

  void _handleAddToCart() {
    if (widget.cartController == null) return;

    widget.cartController!.addItem(
      widget.service,
      quantity: _quantity,
      stainRemoval: _stainRemoval,
      premiumClean: _premiumClean,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity x ${widget.service.name} to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.cobaltBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final illustrationType = _getIllustrationForService(service);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 44,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Centered Sketch Illustration
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.cobaltLight.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: LaundryIllustration(
                            type: illustrationType,
                            size: 64,
                            strokeColor: AppColors.cobaltBlue,
                            strokeWidth: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Category Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        service.customizeCategory.toUpperCase(),
                        style: AppTypography.sans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cobaltBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: AppTypography.sans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${service.price.toStringAsFixed(0)} / ${service.unit}',
                          style: AppTypography.sans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cobaltBlue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Features List
                    if (service.features.isNotEmpty)
                      Column(
                        children: service.features.map((feat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.cobaltBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: AppTypography.sans(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 10),

                    // Quantity Stepper
                    SketchCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity',
                            style: AppTypography.sans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                                  ),
                                  child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$_quantity',
                                  style: AppTypography.sans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() => _quantity++);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.cobaltBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Add-ons
                    if (service.hasStainRemoval || service.hasPremiumClean) ...[
                      Text(
                        'Add-ons (Optional)',
                        style: AppTypography.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      if (service.hasStainRemoval)
                        _buildAddonCheckbox(
                          title: 'Stain Removal Treatment',
                          price: service.stainRemovalPrice,
                          value: _stainRemoval,
                          onChanged: (val) {
                            setState(() => _stainRemoval = val ?? false);
                          },
                        ),

                      if (service.hasPremiumClean)
                        _buildAddonCheckbox(
                          title: 'Premium Antiseptic Wash',
                          price: service.premiumCleanPrice,
                          value: _premiumClean,
                          onChanged: (val) {
                            setState(() => _premiumClean = val ?? false);
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Sticky Bottom Checkout Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: AppColors.cardBorder, width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
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
                        'Total Price',
                        style: AppTypography.sans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${_totalPrice.toStringAsFixed(0)}',
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
                      text: 'Add to Cart',
                      height: 46,
                      onPressed: _handleAddToCart,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCheckbox({
    required String title,
    required double price,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? AppColors.cobaltLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.cobaltBlue : AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.cobaltBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTypography.sans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '+₹${price.toStringAsFixed(0)}',
              style: AppTypography.sans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cobaltBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
