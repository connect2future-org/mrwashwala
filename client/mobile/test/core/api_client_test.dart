import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/core/network/api_exception.dart';

void main() {
  group('ApiClient Tests', () {
    test('GET returns parsed JSON on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer test_token');
        return http.Response(jsonEncode({'success': true, 'data': 'ok'}), 200);
      });

      final apiClient = ApiClient(client: mockClient);
      final response = await apiClient.get('http://test.com/api', token: 'test_token');

      expect(response['success'], isTrue);
      expect(response['data'], 'ok');
    });

    test('POST throws ApiException on 400 Bad Request', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'message': 'Invalid phone number'}),
          400,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.post('http://test.com/api/send-otp', body: {'phone': '123'}),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Invalid phone number')),
      );
    });

    test('Process response handles non-200 server errors', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Server error'}),
          500,
        );
      });

      final apiClient = ApiClient(client: mockClient);

      expect(
        () => apiClient.get('http://test.com/api/error'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });
}
