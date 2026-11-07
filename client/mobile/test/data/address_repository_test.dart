import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/address_repository.dart';

void main() {
  group('AddressRepository Tests', () {
    test('fetchAddresses returns list of AddressModel on 200 OK', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer mock_token');
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'data': [
              {
                'addressId': 'addr-101',
                'label': 'Home',
                'fullAddress': '123 Main St, Vijaynagar',
                'city': 'Mysuru',
                'pincode': '570017',
                'isDefault': true,
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);

      final addresses = await repo.fetchAddresses('mock_token');
      expect(addresses.length, 1);
      expect(addresses.first.addressId, 'addr-101');
      expect(addresses.first.label, 'Home');
      expect(addresses.first.isDefault, true);
    });

    test('addAddress sends POST and returns updated address list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body);
        expect(body['fullAddress'], '456 Saraswathipuram');
        expect(body['pincode'], '570009');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Address added successfully',
            'data': {
              'addressId': 'addr-102',
              'label': 'Work',
              'fullAddress': '456 Saraswathipuram',
              'pincode': '570009',
            },
            'addresses': [
              {
                'addressId': 'addr-102',
                'label': 'Work',
                'fullAddress': '456 Saraswathipuram',
                'pincode': '570009',
              }
            ],
          }),
          201,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);

      final addresses = await repo.addAddress(
        'mock_token',
        fullAddress: '456 Saraswathipuram',
        label: 'Work',
        pincode: '570009',
      );
      expect(addresses.length, 1);
      expect(addresses.first.addressId, 'addr-102');
      expect(addresses.first.label, 'Work');
    });

    test('updateAddress sends PATCH and returns updated address list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path, contains('/addresses/addr-101'));
        final body = jsonDecode(request.body);
        expect(body['isDefault'], true);

        return http.Response(
          jsonEncode({
            'success': true,
            'addresses': [
              {
                'addressId': 'addr-101',
                'label': 'Home',
                'fullAddress': '123 Main St, Vijaynagar',
                'isDefault': true,
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);

      final addresses = await repo.updateAddress(
        'mock_token',
        'addr-101',
        isDefault: true,
      );
      expect(addresses.first.isDefault, true);
    });

    test('deleteAddress sends DELETE and returns remaining addresses', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, contains('/addresses/addr-101'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Address removed successfully',
            'addresses': [],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);

      final addresses = await repo.deleteAddress('mock_token', 'addr-101');
      expect(addresses.isEmpty, true);
    });
  });
}
