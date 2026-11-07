import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import '../../cart/presentation/cart_controller.dart';
import 'service_controller.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  final ServiceController serviceController;
  final CartController? cartController;
  final VoidCallback? onViewCart;

  const ServicesScreen({
    super.key,
    required this.serviceController,
    this.cartController,
    this.onViewCart,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ServiceController _controller;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'Wash & Fold',
    'Dry Cleaning',
    'Shoe Cleaning',
    'Wash & Iron',
    'Customize Your Service',
  ];

  @override
  void initState() {
    super.initState();
    _controller = widget.serviceController;
    if (_controller.services.isEmpty) {
      _controller.fetchServices();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _addToCart(ServiceModel service) {
    if (widget.cartController == null) return;
    widget.cartController!.addItem(service);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${service.name} to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.cobaltBlue,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            if (widget.onViewCart != null) {
              widget.onViewCart!();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search services...',
                  border: InputBorder.none,
                ),
                style: AppTypography.sans(fontSize: 16),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => Text(
                  _controller.selectedCategory,
                  style: AppTypography.sans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (widget.onViewCart != null)
            ListenableBuilder(
              listenable: widget.cartController ?? Listenable.merge([]),
              builder: (context, _) {
                final qty = widget.cartController?.totalQuantity ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.cobaltBlue),
                      onPressed: widget.onViewCart,
                    ),
                    if (qty > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.cobaltBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.cobaltBlue),
              ),
            );
          }

          if (_controller.errorMessage != null && _controller.services.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.sans(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    CobaltButton(
                      text: 'Retry',
                      width: 140,
                      onPressed: () => _controller.fetchServices(),
                    ),
                  ],
                ),
              ),
            );
          }

          var displayedServices = _controller.filteredServices;
          if (_searchQuery.isNotEmpty) {
            displayedServices = displayedServices
                .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          return RefreshIndicator(
            color: AppColors.cobaltBlue,
            onRefresh: () => _controller.fetchServices(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 1. Horizontal Category Filter Pills
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.white,
                    child: SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _controller.selectedCategory == category;
                          return CategoryFilterPill(
                            label: category,
                            isSelected: isSelected,
                            onTap: () {
                              _controller.setCategory(category);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),

                // 2. Services List
                if (displayedServices.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final service = displayedServices[index];
                          return _buildServiceCard(service);
                        },
                        childCount: displayedServices.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final illustrationType = _getIllustrationForService(service);

    return ListenableBuilder(
      listenable: widget.cartController ?? Listenable.merge([]),
      builder: (context, _) {
        final quantity = widget.cartController?.getItemQuantity(service.id) ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailsScreen(
                      service: service,
                      cartController: widget.cartController,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Left Sketch Illustration Circle
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.cobaltLight.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: LaundryIllustration(
                          type: illustrationType,
                          size: 46,
                          strokeColor: AppColors.cobaltBlue,
                          strokeWidth: 1.8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Middle Service Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: AppTypography.sans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            service.features.isNotEmpty
                                ? service.features.first
                                : 'Regular clean & soft finish',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Price
                          Row(
                            children: [
                              Text(
                                '₹${service.price.toStringAsFixed(0)}',
                                style: AppTypography.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ ${service.unit}',
                                style: AppTypography.sans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right Add Button or Quantity Stepper
                    if (quantity > 0)
                      QuantityCounter(
                        quantity: quantity,
                        size: 32,
                        onIncrement: () => widget.cartController?.incrementQuantity(service.id),
                        onDecrement: () => widget.cartController?.decrementQuantity(service.id),
                      )
                    else
                      InkWell(
                        onTap: () => _addToCart(service),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cobaltBlue,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add',
                                style: AppTypography.sans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.add, size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final catName = _controller.selectedCategory;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.cobaltLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: AppColors.cobaltBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No services found in "$catName"',
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no active services matching this filter.',
              textAlign: TextAlign.center,
              style: AppTypography.sans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            CobaltButton(
              text: 'Go to Wash & Fold',
              width: 200,
              onPressed: () => _controller.setCategory('Wash & Fold'),
            ),
          ],
        ),
      ),
    );
  }
}
