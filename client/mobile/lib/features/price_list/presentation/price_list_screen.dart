import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';
import 'price_list_controller.dart';

class PriceListScreen extends StatefulWidget {
  final PriceListController? controller;
  final ServiceRepository? serviceRepository;

  const PriceListScreen({
    super.key,
    this.controller,
    this.serviceRepository,
  });

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  late final PriceListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        PriceListController(
          serviceRepository: widget.serviceRepository ?? ServiceRepository(),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasData && !_controller.isLoading) {
        _controller.loadPriceList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.surfaceWhite,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryNavy,
                size: 20,
              ),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Text(
                  'View our current services and prices.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: _controller.isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryNavy,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primaryNavy,
                      ),
                tooltip: 'Refresh Prices',
                onPressed: _controller.isRefreshing
                    ? null
                    : () => _controller.loadPriceList(isRefresh: true),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    // 1. Initial Loading State
    if (_controller.isLoading && !_controller.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryNavy,
            ),
            SizedBox(height: 16),
            Text(
              'Fetching current price list...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 2. Initial Error State (no data available)
    if (_controller.errorMessage != null && !_controller.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.iceBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Unable to Load Prices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => _controller.loadPriceList(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (no services found)
    if (_controller.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.iceBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No Services Available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our service catalogue is currently being updated. Please check back shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                onPressed: () => _controller.loadPriceList(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Data Available State (supports pull-to-refresh)
    final grouped = _controller.groupedServices;

    return RefreshIndicator(
      color: AppColors.primaryNavy,
      onRefresh: () => _controller.loadPriceList(isRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Refresh Failure Warning Banner
            if (_controller.refreshError != null) ...[
              _buildRefreshWarningBanner(),
              const SizedBox(height: 14),
            ],

            // Pricing Intro Header Card
            _buildPricingIntroBanner(),

            const SizedBox(height: 16),

            // Category Sections
            for (final entry in grouped.entries) ...[
              _buildCategoryCard(entry.key, entry.value),
              const SizedBox(height: 16),
            ],

            // Bottom Informational Footnote
            _buildPriceFootnote(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF856404),
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Could not refresh prices. Showing previously loaded price list.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF856404),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(40, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _controller.loadPriceList(isRefresh: true),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingIntroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.iceBlue.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            color: AppColors.primaryNavy,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transparent & Honest Pricing',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'All prices are in Indian Rupees (₹). Doorstep pickup and hygienic fabric care available across Mysuru.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String categoryName, List<ServiceModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.iceBlue.withValues(alpha: 0.45),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.cardBorder, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                _buildCategoryIcon(categoryName),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'SERVICE / ITEM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PRICE',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Item Rows
          for (int i = 0; i < items.length; i++) ...[
            _buildServiceRow(items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFF0F4F8),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final norm = category.toLowerCase();
    LaundryIllustrationType illType = LaundryIllustrationType.laundryBasket;

    if (norm.contains('wash & fold')) {
      illType = LaundryIllustrationType.washingMachine;
    } else if (norm.contains('wash & iron')) {
      illType = LaundryIllustrationType.iron;
    } else if (norm.contains('dry clean')) {
      illType = LaundryIllustrationType.shirtOnHanger;
    } else if (norm.contains('shoe clean')) {
      illType = LaundryIllustrationType.sneakers;
    } else if (norm.contains('bed sheet') || norm.contains('blanket')) {
      illType = LaundryIllustrationType.foldedTowels;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cobaltBorder, width: 0.8),
      ),
      child: LaundryIllustration(
        type: illType,
        size: 20,
        strokeColor: AppColors.cobaltBlue,
      ),
    );
  }

  Widget _buildServiceRow(ServiceModel service) {
    final hasAddOns = (service.hasStainRemoval && service.stainRemovalPrice > 0) ||
        (service.hasPremiumClean && service.premiumCleanPrice > 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Service Name and Supported Add-on Pricing
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                if (hasAddOns) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (service.hasStainRemoval && service.stainRemovalPrice > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.iceBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+ ₹${service.stainRemovalPrice.toInt()} Stain Removal',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      if (service.hasPremiumClean && service.premiumCleanPrice > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.iceBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+ ₹${service.premiumCleanPrice.toInt()} Premium Clean',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Formatted Price and Distinct Unit
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (service.price > 0)
                  Text(
                    '₹${service.price.toInt() == service.price ? service.price.toInt() : service.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  )
                else
                  const Text(
                    'Custom Quote',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  PriceListController.formatUnit(service.unit),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFootnote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prices are synchronized directly with our live catalogue. Final bill may vary based on item weight or verified count at pickup.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
