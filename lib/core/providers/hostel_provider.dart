import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hostel.dart';
import 'auth_provider.dart';

final hostelListProvider = FutureProvider.family<List<Hostel>, HostelFilters>((ref, filters) async {
  final service = ref.read(backendServiceProvider);
  return service.getHostels(
    city: filters.city,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    amenities: filters.amenities,
    sortBy: filters.sortBy,
    page: filters.page,
    limit: filters.limit,
  );
});

final hostelProvider = FutureProvider.family<Hostel?, String>((ref, hostelId) async {
  final service = ref.read(backendServiceProvider);
  return service.getHostelById(hostelId);
});

final searchHostelsProvider = FutureProvider.family<List<Hostel>, String>((ref, query) async {
  final service = ref.read(backendServiceProvider);
  if (query.isEmpty) return [];
  return service.searchHostels(query);
});

final favoriteHostelIdsProvider = StateProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.favoriteHostelIds ?? [];
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, hostelId) async {
  final service = ref.read(backendServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return service.isFavorite(hostelId, user.id);
});

class HostelFilters {
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? amenities;
  final String? sortBy;
  final int page;
  final int limit;

  HostelFilters({
    this.city,
    this.minPrice,
    this.maxPrice,
    this.amenities,
    this.sortBy,
    this.page = 0,
    this.limit = 20,
  });

  HostelFilters copyWith({
    String? city,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? sortBy,
    int? page,
    int? limit,
  }) {
    return HostelFilters(
      city: city ?? this.city,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

