import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mrwashwala_mobile/core/network/api_client.dart';
import 'package:mrwashwala_mobile/data/models/address_model.dart';
import 'package:mrwashwala_mobile/data/repositories/address_repository.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/add_edit_address_screen.dart';
import 'package:mrwashwala_mobile/features/addresses/presentation/address_controller.dart';

void main() {
  group('AddEditAddressScreen Widget Tests', () {
    late AddressController controller;

    setUp(() {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'success': true, 'data': {}}), 200);
      });
      controller = AddressController(
        addressRepository: AddressRepository(apiClient: ApiClient(client: mockClient)),
      );
    });

    testWidgets('Renders all fields for new address and validates required inputs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditAddressScreen(
            addressController: controller,
            token: 'test_token',
          ),
        ),
      );

      expect(find.text('Add New Delivery Address'), findsOneWidget);
      expect(find.text('Address Type'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Save Address'), findsOneWidget);

      // Tap Save Address without entering anything to trigger validation
      await tester.tap(find.text('Save Address'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter full address'), findsOneWidget);
      expect(find.text('Pincode required'), findsOneWidget);
    });

    testWidgets('Pre-fills existing address data when editing', (tester) async {
      final existingAddr = AddressModel(
        addressId: 'addr-existing',
        label: 'Work',
        fullAddress: 'Infosys Campus, Hebbal Industrial Area',
        houseNo: 'Building 12',
        street: 'Ring Road',
        landmark: 'Opposite Main Gate',
        city: 'Mysuru',
        pincode: '570027',
        isDefault: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddEditAddressScreen(
            addressController: controller,
            token: 'test_token',
            addressToEdit: existingAddr,
          ),
        ),
      );

      expect(find.text('Edit Delivery Address'), findsOneWidget);
      expect(find.text('Infosys Campus, Hebbal Industrial Area'), findsOneWidget);
      expect(find.text('Building 12'), findsOneWidget);
      expect(find.text('Ring Road'), findsOneWidget);
      expect(find.text('Opposite Main Gate'), findsOneWidget);
      expect(find.text('570027'), findsOneWidget);
      expect(find.text('Update Address'), findsOneWidget);
    });
  });
}
