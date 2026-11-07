import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../shared/widgets/laundry_illustrations.dart';
import '../../../shared/widgets/sketch_widgets.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../services/presentation/service_controller.dart';

class HomeScreen extends StatefulWidget {
  final ServiceController serviceController;
  final CartController? cartController;
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    required this.serviceController,
    this.cartController,
    this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ServiceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.serviceController;
    if (_controller.services.isEmpty) {
      _controller.fetchServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: Location, Brand & Notification
              _buildTopHeader(),

              const SizedBox(height: 18),

              // 2. Hero Promotional Card: Cobalt Blue with Clean Clothes Happier Days & Folded Towels
              _buildHeroBanner(),

              const SizedBox(height: 28),

              // 3. Our Services Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Services',
                    style: AppTypography.sans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.setCategory('Wash & Fold');
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1);
                      }
                    },
                    child: Text(
                      'See All',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cobaltBlue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 4. Horizontal Scrolling Service Category Cards
              _buildHorizontalCategories(),

              const SizedBox(height: 28),

              // 5. How Mr. WashWala Works Process Card
              _buildProcessFeatureCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cobaltLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.cobaltBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Home',
                      style: AppTypography.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                Text(
                  'HSR Layout, Bengaluru',
                  style: AppTypography.sans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Brand & Notification Bell
        Row(
          children: [
            Text(
              'WashWala',
              style: AppTypography.display(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.cobaltBlue,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cobaltBlue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.cobaltBlue.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Content
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Clean Clothes\nHappier Days',
                  style: AppTypography.display(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    _controller.setCategory('Wash & Fold');
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(1);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Book Now',
                          style: AppTypography.sans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cobaltBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.cobaltBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Folded Towels Sketch Illustration
          const Expanded(
            flex: 4,
            child: Center(
              child: LaundryIllustration(
                type: LaundryIllustrationType.foldedTowels,
                size: 95,
                strokeColor: Colors.white,
                strokeWidth: 2.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCategories() {
    final categories = [
      {
        'title': 'Wash & Fold',
        'subtitle': 'Regular everyday laundry, fresh & neatly folded',
        'type': LaundryIllustrationType.laundryBasket,
      },
      {
        'title': 'Dry Cleaning',
        'subtitle': 'Suits, blazers, silk & delicate garments',
        'type': LaundryIllustrationType.shirtOnHanger,
      },
      {
        'title': 'Shoe Cleaning',
        'subtitle': 'Sneakers, sports shoes, leather & suede',
        'type': LaundryIllustrationType.sneakers,
      },
      {
        'title': 'Wash & Iron',
        'subtitle': 'Steam pressed, crisp & ready to wear',
        'type': LaundryIllustrationType.iron,
      },
      {
        'title': 'Customize Your Service',
        'subtitle': 'Blankets, curtains, bags & custom requests',
        'type': LaundryIllustrationType.tshirt,
      },
    ];

    return SizedBox(
      height: 175,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = categories[index];
          final title = item['title'] as String;
          final type = item['type'] as LaundryIllustrationType;

          return GestureDetector(
            onTap: () {
              _controller.setCategory(title);
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(1);
              }
            },
            child: Container(
              width: 135,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.cobaltLight.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: LaundryIllustration(
                        type: type,
                        size: 54,
                        strokeColor: AppColors.cobaltBlue,
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessFeatureCard() {
    return SketchCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.cobaltBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'How Mr. WashWala Works',
                style: AppTypography.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepTile('1', 'Schedule', Icons.calendar_today_outlined),
              _buildStepDivider(),
              _buildStepTile('2', 'Pickup', Icons.local_shipping_outlined),
              _buildStepDivider(),
              _buildStepTile('3', 'Clean', Icons.local_laundry_service_outlined),
              _buildStepDivider(),
              _buildStepTile('4', 'Deliver', Icons.check_circle_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(String step, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.cobaltLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.cobaltBlue, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return const Icon(
      Icons.chevron_right_rounded,
      size: 14,
      color: AppColors.textMuted,
    );
  }
}
