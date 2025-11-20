import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hostel_finder/core/providers/hostel_provider.dart';
import 'package:hostel_finder/core/services/mock_backend_service.dart';
import 'package:hostel_finder/core/constants/app_constants.dart';

void main() {
  late ProviderContainer container;
  late MockBackendService mockService;

  setUp(() {
    container = ProviderContainer();
    mockService = MockBackendService();
  });

  tearDown(() {
    container.dispose();
  });

  group('Hostel Provider Tests', () {
    test('should load hostels with default filters', () async {
      // Initialize the service
      await mockService.initialize();

      // Create filters
      final filters = HostelFilters(
        page: 0,
        limit: 20,
      );

      // Get hostels
      final hostelsAsync = container.read(hostelListProvider(filters));

      // Wait for the future to complete
      final hostels = await hostelsAsync.requireValue;

      // Verify hostels are loaded
      expect(hostels, isA<List>());
      expect(hostels.length, greaterThan(0));
    });

    test('should filter hostels by city', () async {
      await mockService.initialize();

      final filters = HostelFilters(
        city: 'Lahore',
        page: 0,
        limit: 20,
      );

      final hostelsAsync = container.read(hostelListProvider(filters));
      final hostels = await hostelsAsync.requireValue;

      // Verify all hostels are from Lahore
      for (final hostel in hostels) {
        expect(hostel.city.toLowerCase(), contains('lahore'));
      }
    });

    test('should filter hostels by price range', () async {
      await mockService.initialize();

      final filters = HostelFilters(
        minPrice: 4000,
        maxPrice: 10000,
        page: 0,
        limit: 20,
      );

      final hostelsAsync = container.read(hostelListProvider(filters));
      final hostels = await hostelsAsync.requireValue;

      // Verify price ranges are within filter
      for (final hostel in hostels) {
        expect(hostel.priceRange.min, greaterThanOrEqualTo(4000));
        expect(hostel.priceRange.max, lessThanOrEqualTo(10000));
      }
    });

    test('should sort hostels by rating', () async {
      await mockService.initialize();

      final filters = HostelFilters(
        sortBy: AppConstants.sortRating,
        page: 0,
        limit: 20,
      );

      final hostelsAsync = container.read(hostelListProvider(filters));
      final hostels = await hostelsAsync.requireValue;

      // Verify sorting (descending rating)
      for (int i = 0; i < hostels.length - 1; i++) {
        expect(hostels[i].rating, greaterThanOrEqualTo(hostels[i + 1].rating));
      }
    });
  });
}

