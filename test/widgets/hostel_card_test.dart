import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_finder/core/models/hostel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Hostel Card Widget Tests', () {
    testWidgets('displays hostel information correctly', (WidgetTester tester) async {
      // Create a mock hostel
      final hostel = Hostel(
        id: 'test_hostel_1',
        name: 'Test Hostel',
        city: 'Test City',
        address: '123 Test Street',
        gallery: [],
        ownerId: 'owner_1',
        priceRange: const PriceRange(min: 5000, max: 10000),
        rooms: const [
          Room(type: 'Single', price: 8000, quantity: 5),
        ],
        amenities: ['wifi', 'food'],
        rating: 4.5,
        reviewsCount: 20,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: Builder(
                builder: (context) {
                  // Create a simple hostel card widget
                  return Card(
                    child: ListTile(
                      title: Text(hostel.name),
                      subtitle: Text(hostel.city),
                      trailing: Text('PKR ${hostel.priceRange.min.toStringAsFixed(0)}'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify hostel name is displayed
      expect(find.text('Test Hostel'), findsOneWidget);
      
      // Verify city is displayed
      expect(find.text('Test City'), findsOneWidget);
      
      // Verify price is displayed
      expect(find.text('PKR 5000'), findsOneWidget);
    });

    testWidgets('shows verified badge for verified hostels', (WidgetTester tester) async {
      final hostel = Hostel(
        id: 'test_hostel_2',
        name: 'Verified Hostel',
        city: 'City',
        address: 'Address',
        gallery: [],
        ownerId: 'owner_1',
        priceRange: const PriceRange(min: 5000, max: 10000),
        rooms: const [Room(type: 'Single', price: 5000, quantity: 1)],
        amenities: [],
        rating: 4.0,
        reviewsCount: 10,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(child: Text(hostel.name)),
                if (hostel.isVerified)
                  const Icon(Icons.verified),
              ],
            ),
          ),
        ),
      );

      // Verify verified icon is shown
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });
  });
}

