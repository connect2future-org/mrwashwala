import 'package:flutter/material.dart';
import '../../features/orders/presentation/customer_order_controller.dart';
import '../../features/orders/presentation/order_details_screen.dart';

enum NotificationPermissionStatus {
  notRequested,
  granted,
  denied,
  unavailable,
}

class NotificationPayload {
  final String type; // 'order_status', 'promo', 'general'
  final String title;
  final String body;
  final String? orderId;
  final String? status;
  final DateTime timestamp;

  NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.orderId,
    this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? 'Mr. WashWala Alert',
      body: json['body']?.toString() ?? '',
      orderId: json['orderId']?.toString(),
      status: json['status']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'orderId': orderId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isOrderNotification => type == 'order_status' && orderId != null && orderId!.isNotEmpty;
}

class NotificationService extends ChangeNotifier {
  NotificationPermissionStatus _permissionStatus = NotificationPermissionStatus.notRequested;
  String? _deviceToken;
  bool _isInitialized = false;
  NotificationPayload? _lastReceivedPayload;

  NotificationPermissionStatus get permissionStatus => _permissionStatus;
  String? get deviceToken => _deviceToken;
  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _permissionStatus == NotificationPermissionStatus.granted;
  NotificationPayload? get lastReceivedPayload => _lastReceivedPayload;

  /// Initializes the local notification service architecture.
  Future<void> initialize() async {
    _isInitialized = true;
    notifyListeners();
  }

  /// Requests notification permission from user.
  Future<NotificationPermissionStatus> requestPermission() async {
    _permissionStatus = NotificationPermissionStatus.granted;
    notifyListeners();
    return _permissionStatus;
  }

  /// Denies permission for testing/fallback.
  void denyPermission() {
    _permissionStatus = NotificationPermissionStatus.denied;
    notifyListeners();
  }

  /// Simulates/Retrieves device token for FCM push readiness.
  Future<String?> getDeviceToken() async {
    return _deviceToken;
  }

  /// Sets device token when real push provider generates one.
  void setDeviceToken(String token) {
    _deviceToken = token;
    notifyListeners();
  }

  /// Simulates receiving an in-app foreground notification.
  void handleForegroundNotification(NotificationPayload payload) {
    _lastReceivedPayload = payload;
    notifyListeners();
  }

  /// Displays an in-app SnackBar notification banner for foreground alerts.
  void showInAppNotification(BuildContext context, NotificationPayload payload, {VoidCallback? onTap}) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF0F172A),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF0EA5E9)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payload.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                  ),
                  Text(
                    payload.body,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        action: onTap != null
            ? SnackBarAction(
                label: 'VIEW',
                textColor: const Color(0xFF0EA5E9),
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  /// Handles notification tap and navigates deep-link toward Order Details if applicable.
  Future<bool> handleNotificationTap(
    BuildContext context,
    NotificationPayload payload, {
    CustomerOrderController? orderController,
    String? token,
  }) async {
    if (payload.isOrderNotification) {
      if (orderController != null && token != null) {
        try {
          final order = await orderController.fetchOrderDetails(token, payload.orderId!);
          if (order != null && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(order: order),
              ),
            );
            return true;
          }
        } catch (_) {}
      }
    }
    return false;
  }
}
