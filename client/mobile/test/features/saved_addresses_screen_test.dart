import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/repositories/address_repository.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/address_controller.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/saved_addresses_screen.dart';

void main() {
  group('SavedAddressesScreen Widget Tests', () {
    testWidgets('Renders empty state when no saved addresses exist', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'success': true, 'count': 0, 'data': []}),
          200,
        );
      });

      final controller = AddressController(
        addressRepository: AddressRepository(apiClient: ApiClient(client: mockClient)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SavedAddressesScreen(
            addressController: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(find.text('No Saved Addresses'), findsOneWidget);
      expect(find.text('Add Delivery Address'), findsOneWidget);
    });

    testWidgets('Renders address cards with label and default tag', (tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'count': 2,
            'data': [
              {
                'addressId': 'addr-1',
                'label': 'Home',
                'fullAddress': '#123 4th Main, Jayalakshmipuram',
                'houseNo': '123',
                'street': '4th Main',
                'city': 'Mysuru',
                'pincode': '570012',
                'isDefault': true,
              },
              {
                'addressId': 'addr-2',
                'label': 'Work',
                'fullAddress': 'Tech Park, Vijayanagar 2nd Stage',
                'city': 'Mysuru',
                'pincode': '570017',
                'isDefault': false,
              }
            ],
          }),
          200,
        );
      });

      final controller = AddressController(
        addressRepository: AddressRepository(apiClient: ApiClient(client: mockClient)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SavedAddressesScreen(
            addressController: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('#123 4th Main, Jayalakshmipuram'), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.text('Tech Park, Vijayanagar 2nd Stage'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });
  });
}
