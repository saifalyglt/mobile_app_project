import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/hostel.dart';
import '../models/booking.dart';
import '../models/user_model.dart';
import '../models/review.dart';
import '../constants/app_constants.dart';

/// Mock backend service that simulates API calls
/// This service can be replaced with Firebase or REST API implementation
class MockBackendService {
  static final MockBackendService _instance = MockBackendService._internal();
  factory MockBackendService() => _instance;
  MockBackendService._internal();

  final _uuid = const Uuid();
  List<Hostel> _hostels = [];
  List<Booking> _bookings = [];
  List<AppUser> _users = [];
  List<Review> _reviews = [];
  AppUser? _currentUser;
  bool _initialized = false;

  /// Initialize with sample data
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load sample hostels
      final hostelsJson = await rootBundle.loadString(AppConstants.sampleHostelsPath);
      final List<dynamic> hostelsData = json.decode(hostelsJson);
      _hostels = hostelsData.map((json) => Hostel.fromJson(json)).toList();

      // Load sample users
      final usersJson = await rootBundle.loadString(AppConstants.sampleUsersPath);
      final List<dynamic> usersData = json.decode(usersJson);
      _users = usersData.map((json) => AppUser.fromJson(json)).toList();

      // Generate sample reviews
      _generateSampleReviews();

      _initialized = true;
    } catch (e) {
      // If files don't exist, create default sample data
      _createDefaultSampleData();
      _initialized = true;
    }
  }

  void _createDefaultSampleData() {
    _hostels = [
      Hostel(
        id: 'hostel_1',
        name: 'Green Valley Boys Hostel',
        city: 'Lahore',
        address: '123 ABC Road, Model Town',
        coordinates: const Coordinates(lat: 31.5204, lng: 74.3587),
        thumbnailUrl: null,
        gallery: [],
        ownerId: 'owner_1',
        priceRange: const PriceRange(min: 3000, max: 12000),
        rooms: [
          const Room(type: 'Single', price: 8000, quantity: 5, availableQuantity: 2),
          const Room(type: 'Shared', price: 4000, quantity: 12, availableQuantity: 8),
        ],
        amenities: ['wifi', 'electricity_backup', 'food', 'security'],
        rating: 4.5,
        reviewsCount: 34,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        description: 'A comfortable and secure hostel with modern amenities.',
        phoneNumber: '+92-300-1234567',
        email: 'greenvalley@example.com',
      ),
      Hostel(
        id: 'hostel_2',
        name: 'City View Girls Hostel',
        city: 'Karachi',
        address: '456 XYZ Street, Clifton',
        coordinates: const Coordinates(lat: 24.8138, lng: 67.0289),
        thumbnailUrl: null,
        gallery: [],
        ownerId: 'owner_2',
        priceRange: const PriceRange(min: 5000, max: 15000),
        rooms: [
          const Room(type: 'Single', price: 12000, quantity: 10, availableQuantity: 3),
          const Room(type: 'Double', price: 8000, quantity: 8, availableQuantity: 5),
        ],
        amenities: ['wifi', 'food', 'security', 'ac', 'laundry'],
        rating: 4.8,
        reviewsCount: 56,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        description: 'Premium hostel facility with AC and modern facilities.',
        phoneNumber: '+92-300-7654321',
        email: 'cityview@example.com',
      ),
    ];

    _users = [
      AppUser(
        id: 'user_1',
        email: 'student@example.com',
        name: 'Ahmed Ali',
        phoneNumber: '+92-300-1111111',
        role: AppConstants.roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
    ];

    _generateSampleReviews();
  }

  void _generateSampleReviews() {
    _reviews = [
      Review(
        id: 'review_1',
        hostelId: 'hostel_1',
        userId: 'user_1',
        userName: 'Ahmed Ali',
        rating: 4.5,
        comment: 'Great place with good facilities and friendly staff.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Auth Methods
  Future<AppUser?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('User not found'),
    );
    
    _currentUser = user;
    return user;
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final newUser = AppUser(
      id: _uuid.v4(),
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
      createdAt: DateTime.now(),
      favoriteHostelIds: [],
      isOwnerVerified: role == AppConstants.roleOwner ? false : null,
    );
    
    _users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  AppUser? get currentUser => _currentUser;

  // Hostel Methods
  Future<List<Hostel>> getHostels({
    String? city,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? sortBy,
    int page = 0,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    List<Hostel> filtered = List.from(_hostels);
    
    if (city != null && city.isNotEmpty) {
      filtered = filtered.where((h) => h.city.toLowerCase().contains(city.toLowerCase())).toList();
    }
    
    if (minPrice != null) {
      filtered = filtered.where((h) => h.priceRange.min >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      filtered = filtered.where((h) => h.priceRange.max <= maxPrice).toList();
    }
    
    if (amenities != null && amenities.isNotEmpty) {
      filtered = filtered.where((h) {
        return amenities.every((amenity) => h.amenities.contains(amenity));
      }).toList();
    }
    
    // Sorting
    switch (sortBy) {
      case AppConstants.sortPriceLowHigh:
        filtered.sort((a, b) => a.priceRange.min.compareTo(b.priceRange.min));
        break;
      case AppConstants.sortPriceHighLow:
        filtered.sort((a, b) => b.priceRange.max.compareTo(a.priceRange.max));
        break;
      case AppConstants.sortRating:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case AppConstants.sortNewest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    // Pagination
    final start = page * limit;
    final end = (start + limit).clamp(0, filtered.length);
    
    return filtered.sublist(start, end);
  }

  Future<Hostel?> getHostelById(String hostelId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _hostels.firstWhere((h) => h.id == hostelId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Hostel>> searchHostels(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _hostels.where((h) {
      return h.name.toLowerCase().contains(query.toLowerCase()) ||
          h.city.toLowerCase().contains(query.toLowerCase()) ||
          h.address.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Booking Methods
  Future<Booking> createBooking({
    required String hostelId,
    required String userId,
    required String roomType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
    String? paymentMethod,
    String? transactionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final booking = Booking(
      id: _uuid.v4(),
      hostelId: hostelId,
      userId: userId,
      roomType: roomType,
      startDate: startDate,
      endDate: endDate,
      amount: amount,
      status: AppConstants.bookingStatusConfirmed,
      createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );
    
    _bookings.add(booking);
    return booking;
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final bookings = _bookings.where((b) => b.userId == userId).toList();
    
    // Populate hostel info
    return bookings.map((booking) {
      final hostel = _hostels.firstWhere(
        (h) => h.id == booking.hostelId,
        orElse: () => throw Exception('Hostel not found'),
      );
      return booking.copyWith(hostel: hostel);
    }).toList();
  }

  Future<Booking?> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: AppConstants.bookingStatusCancelled,
        updatedAt: DateTime.now(),
      );
      return _bookings[index];
    }
    return null;
  }

  // Review Methods
  Future<Review> createReview({
    required String hostelId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    String? userPhotoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final review = Review(
      id: _uuid.v4(),
      hostelId: hostelId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    
    _reviews.add(review);
    
    // Update hostel rating
    final hostelIndex = _hostels.indexWhere((h) => h.id == hostelId);
    if (hostelIndex != -1) {
      final hostelReviews = _reviews.where((r) => r.hostelId == hostelId).toList();
      final avgRating = hostelReviews.map((r) => r.rating).reduce((a, b) => a + b) / hostelReviews.length;
      _hostels[hostelIndex] = _hostels[hostelIndex].copyWith(
        rating: avgRating,
        reviewsCount: hostelReviews.length,
      );
    }
    
    return review;
  }

  Future<List<Review>> getHostelReviews(String hostelId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _reviews.where((r) => r.hostelId == hostelId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Favorite Methods
  Future<void> toggleFavorite(String hostelId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      final user = _users[userIndex];
      final favorites = List<String>.from(user.favoriteHostelIds ?? []);
      
      if (favorites.contains(hostelId)) {
        favorites.remove(hostelId);
      } else {
        favorites.add(hostelId);
      }
      
      _users[userIndex] = user.copyWith(favoriteHostelIds: favorites);
      if (_currentUser?.id == userId) {
        _currentUser = _users[userIndex];
      }
    }
  }

  Future<bool> isFavorite(String hostelId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final user = _users.firstWhere((u) => u.id == userId, orElse: () => throw Exception('User not found'));
    return user.favoriteHostelIds?.contains(hostelId) ?? false;
  }

  // Owner Methods
  Future<Hostel> createHostel({
    required String ownerId,
    required String name,
    required String city,
    required String address,
    required PriceRange priceRange,
    required List<Room> rooms,
    required List<String> amenities,
    String? description,
    String? phoneNumber,
    String? email,
    Coordinates? coordinates,
    List<String>? gallery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final hostel = Hostel(
      id: _uuid.v4(),
      name: name,
      city: city,
      address: address,
      coordinates: coordinates,
      gallery: gallery ?? [],
      ownerId: ownerId,
      priceRange: priceRange,
      rooms: rooms,
      amenities: amenities,
      rating: 0.0,
      reviewsCount: 0,
      isVerified: false,
      createdAt: DateTime.now(),
      description: description,
      phoneNumber: phoneNumber,
      email: email,
    );
    
    _hostels.add(hostel);
    return hostel;
  }

  Future<Hostel> updateHostel(Hostel hostel) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _hostels.indexWhere((h) => h.id == hostel.id);
    if (index != -1) {
      _hostels[index] = hostel;
      return _hostels[index];
    }
    throw Exception('Hostel not found');
  }

  Future<List<Booking>> getOwnerBookings(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ownerHostels = _hostels.where((h) => h.ownerId == ownerId).map((h) => h.id).toList();
    return _bookings.where((b) => ownerHostels.contains(b.hostelId)).toList();
  }

  // Admin Methods
  Future<List<AppUser>> getPendingOwnerVerifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.where((u) => 
      u.role == AppConstants.roleOwner && (u.isOwnerVerified == false)
    ).toList();
  }

  Future<void> verifyOwner(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isOwnerVerified: true);
    }
  }
}

