class AppConstants {
  // App Info
  static const String appName = 'Hostel Finder';
  static const String appVersion = '1.0.0';

  // Roles
  static const String roleStudent = 'student';
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';

  // Booking Status
  static const String bookingStatusPending = 'pending';
  static const String bookingStatusConfirmed = 'confirmed';
  static const String bookingStatusCancelled = 'cancelled';

  // Hostel Amenities
  static const String amenityWifi = 'wifi';
  static const String amenityElectricityBackup = 'electricity_backup';
  static const String amenityFood = 'food';
  static const String amenitySecurity = 'security';
  static const String amenityLaundry = 'laundry';
  static const String amenityParking = 'parking';
  static const String amenityAC = 'ac';
  static const String amenityGym = 'gym';

  // Room Types
  static const String roomTypeSingle = 'Single';
  static const String roomTypeShared = 'Shared';
  static const String roomTypeDouble = 'Double';
  static const String roomTypeTriple = 'Triple';

  // Sorting Options
  static const String sortPriceLowHigh = 'price_low_high';
  static const String sortPriceHighLow = 'price_high_low';
  static const String sortRating = 'rating';
  static const String sortNewest = 'newest';

  // Mock Data Files
  static const String sampleHostelsPath = 'assets/data/sample_hostels.json';
  static const String sampleUsersPath = 'assets/data/sample_users.json';

  // Cache Keys
  static const String cacheHostelsKey = 'cached_hostels';
  static const String cacheUserKey = 'cached_user';
}

