import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class OrderStatusHelper {
  static const List<String> trackingSteps = [
    'Pending',
    'Picked Up',
    'In Process',
    'Out for Delivery',
    'Delivered',
  ];

  /// Returns 0-based step index for timeline progress. Returns -1 for Cancelled.
  static int getStatusStepIndex(String status) {
    final index = trackingSteps.indexOf(status);
    return index >= 0 ? index : 0;
  }

  /// Returns theme color associated with order status
  static Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warningOrange;
      case 'Picked Up':
        return Colors.indigo;
      case 'In Process':
        return AppColors.accentCyan;
      case 'Out for Delivery':
        return Colors.purple;
      case 'Delivered':
        return AppColors.successGreen;
      case 'Cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.primaryNavy;
    }
  }

  /// Returns user-friendly status text
  static String getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Order Placed';
      case 'Picked Up':
        return 'Picked Up';
      case 'In Process':
        return 'Cleaning In Process';
      case 'Out for Delivery':
        return 'Out for Delivery';
      case 'Delivered':
        return 'Delivered & Completed';
      case 'Cancelled':
        return 'Order Cancelled';
      default:
        return status;
    }
  }

  /// Returns icon for status step
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.receipt_long;
      case 'Picked Up':
        return Icons.local_shipping;
      case 'In Process':
        return Icons.local_laundry_service;
      case 'Out for Delivery':
        return Icons.delivery_dining;
      case 'Delivered':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
