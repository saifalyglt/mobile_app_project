// TODO: ADD FIREBASE KEYS
// This file contains Firebase service stubs
// To use Firebase:
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Add your Android/iOS apps to the project
// 3. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
// 4. Place them in android/app/ and ios/Runner/ respectively
// 5. Add your Firebase config keys below
// 6. Uncomment and implement the methods below

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/hostel.dart';
import '../models/booking.dart';
import '../models/user_model.dart';
import '../models/review.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await _getUserFromFirestore(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = AppUser(
        id: credential.user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        favoriteHostelIds: [],
        isOwnerVerified: role == AppConstants.roleOwner ? false : null,
      );
      
      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    // TODO: Fetch from Firestore
    return null;
  }

  // Hostel Methods
  Future<List<Hostel>> getHostels({
    String? city,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? sortBy,
  }) async {
    Query query = _firestore.collection('hostels');
    
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Hostel.fromJson(doc.data())).toList();
  }

  Future<Hostel?> getHostelById(String hostelId) async {
    final doc = await _firestore.collection('hostels').doc(hostelId).get();
    if (doc.exists) {
      return Hostel.fromJson(doc.data()!);
    }
    return null;
  }

  // Booking Methods
  Future<Booking> createBooking({
    required String hostelId,
    required String userId,
    required String roomType,
    required DateTime startDate,
    required DateTime endDate,
    required double amount,
  }) async {
    final booking = Booking(
      id: _firestore.collection('bookings').doc().id,
      hostelId: hostelId,
      userId: userId,
      roomType: roomType,
      startDate: startDate,
      endDate: endDate,
      amount: amount,
      status: AppConstants.bookingStatusPending,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('bookings').doc(booking.id).set(booking.toJson());
    return booking;
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();
    
    return snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
  }

  // Helper Methods
  Future<AppUser?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromJson(doc.data()!);
    }
    return null;
  }
}
*/

// Placeholder implementation that uses mock service
import 'mock_backend_service.dart';
import '../models/user_model.dart';

class FirebaseService {
  final MockBackendService _mockService = MockBackendService();
  
  // All methods delegate to mock service until Firebase is configured
  Future<void> initialize() => _mockService.initialize();
  Future<AppUser?> signIn(String email, String password) => _mockService.signIn(email, password);
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) => _mockService.signUp(
    email: email,
    password: password,
    name: name,
    role: role,
    phoneNumber: phoneNumber,
  );
  Future<void> signOut() => _mockService.signOut();
  AppUser? get currentUser => _mockService.currentUser;
}

