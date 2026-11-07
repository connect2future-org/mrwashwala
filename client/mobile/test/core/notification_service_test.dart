import 'package:flutter_test/flutter_test.dart';
import 'package:mrwashwala_mobile/core/services/notification_service.dart';

void main() {
  group('NotificationService Architecture & Flow Tests', () {
    test('initial state has notRequested permission and null token', () {
      final service = NotificationService();
      expect(service.isInitialized, false);
      expect(service.permissionStatus, NotificationPermissionStatus.notRequested);
      expect(service.deviceToken, null);
      expect(service.isPermissionGranted, false);
    });

    test('initialize sets isInitialized to true', () async {
      final service = NotificationService();
      await service.initialize();
      expect(service.isInitialized, true);
    });

    test('requestPermission grants notification permission', () async {
      final service = NotificationService();
      final status = await service.requestPermission();
      expect(status, NotificationPermissionStatus.granted);
      expect(service.isPermissionGranted, true);
    });

    test('denyPermission sets status to denied', () {
      final service = NotificationService();
      service.denyPermission();
      expect(service.permissionStatus, NotificationPermissionStatus.denied);
      expect(service.isPermissionGranted, false);
    });

    test('setDeviceToken stores push device token for FCM readiness', () async {
      final service = NotificationService();
      service.setDeviceToken('fcm_token_sample_12345');
      expect(await service.getDeviceToken(), 'fcm_token_sample_12345');
    });

    test('NotificationPayload parses order notification JSON cleanly', () {
      final json = {
        'type': 'order_status',
        'title': 'Order Out for Delivery',
        'body': 'Your clothes are on the way!',
        'orderId': 'MRW-987654',
        'status': 'Out for Delivery',
      };

      final payload = NotificationPayload.fromJson(json);
      expect(payload.type, 'order_status');
      expect(payload.title, 'Order Out for Delivery');
      expect(payload.orderId, 'MRW-987654');
      expect(payload.isOrderNotification, true);
    });

    test('handleForegroundNotification updates lastReceivedPayload', () {
      final service = NotificationService();
      final payload = NotificationPayload(
        type: 'order_status',
        title: 'Order Delivered',
        body: 'Laundry delivered successfully',
        orderId: 'MRW-112233',
      );

      service.handleForegroundNotification(payload);
      expect(service.lastReceivedPayload, payload);
      expect(service.lastReceivedPayload?.orderId, 'MRW-112233');
    });
  });
}
