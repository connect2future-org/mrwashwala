import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/address_repository.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/address_controller.dart';

void main() {
  group('AddressController Tests', () {
    test('loadAddresses populates saved addresses on success', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 1,
            'data': [
              {
                'addressId': 'addr-999',
                'label': 'Home',
                'fullAddress': '777 Saraswathipuram',
                'city': 'Mysuru',
                'pincode': '570009',
                'isDefault': true,
              }
            ],
          }),
          200,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);
      final controller = AddressController(addressRepository: repo);

      await controller.loadAddresses('valid_token');
      expect(controller.isLoading, false);
      expect(controller.hasAddresses, true);
      expect(controller.addresses.length, 1);
      expect(controller.defaultAddress?.addressId, 'addr-999');
    });

    test('addAddress handles failure and sets errorMessage', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Full address is required',
          }),
          400,
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final repo = AddressRepository(apiClient: apiClient);
      final controller = AddressController(addressRepository: repo);

      final success = await controller.addAddress(
        'valid_token',
        fullAddress: '',
      );
      expect(success, false);
      expect(controller.errorMessage, contains('Full delivery address is required'));
    });
  });
}
