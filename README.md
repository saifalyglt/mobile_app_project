# Hostel Finder & Booking App
Under development == Getting Errors and trying to resolve tbem.

A complete Flutter mobile application for finding and booking hostels. Built for both Android and iOS platforms.

## Features

### Core Features
- ✅ **Onboarding & Authentication**: Simple 3-slide onboarding, email/password sign in/sign up, and placeholders for social login (Google, Apple)
- ✅ **Multi-role Support**: Student/User, Hostel Owner, and Admin roles with separate flows
- ✅ **Home & Explore**: Browse hostels by city, search functionality, quick filters, and sorting options
- ✅ **Hostel Listing**: Card-based view with thumbnails, ratings, amenities badges, and infinite scroll support
- ✅ **Hostel Details**: Full gallery carousel, detailed description, room types, amenities, reviews, and contact information
- ✅ **Booking Flow**: Room selection, date picker, price summary, mock payment flow, and confirmation screen
- ✅ **User Profile**: View bookings history, manage favorites, and profile settings
- ✅ **Owner Dashboard**: Add/edit hostel listings, manage bookings, view verification status
- ✅ **Admin Tools**: Approve/reject owner registrations, view metrics dashboard
- ✅ **Reviews & Ratings**: Students can leave reviews; owners cannot self-review
- ✅ **Offline Support**: Basic caching for hostel listings
- ✅ **Localization Ready**: English and Urdu (placeholder) support

## Technical Stack

- **Flutter**: Latest stable (3.x / 4.x compatible)
- **State Management**: Riverpod
- **Routing**: go_router
- **Backend Options**:
  - Mock Backend Service (default, works without setup)
  - Firebase Integration (stubs provided, requires Firebase project)
- **Testing**: Unit tests and widget tests included
- **Localization**: ARB files with English and Urdu

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants
│   ├── models/             # Data models (Hostel, Booking, User, Review)
│   ├── providers/          # Riverpod providers
│   ├── routing/            # App routing configuration
│   ├── services/           # Backend services (Mock & Firebase)
│   ├── theme/              # App theme and styling
│   └── utils/              # Utility functions
├── features/
│   ├── auth/               # Authentication screens
│   ├── onboarding/         # Onboarding flow
│   ├── home/               # Home screen
│   ├── hostel_list/        # Hostel listing screen
│   ├── hostel_detail/      # Hostel detail screen
│   ├── booking/            # Booking flow screens
│   ├── profile/            # User profile screen
│   ├── owner/              # Owner management screens
│   ├── admin/              # Admin dashboard
│   └── reviews/            # Reviews widgets
├── shared/
│   └── widgets/            # Shared UI components
└── l10n/                   # Localization files
```

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for iOS development)
- Git

### Installation

1. **Clone the repository** (or navigate to the project directory)

```bash
cd hostel_finder
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Generate model files**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**

```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```

## Running in Demo Mode (Mock Backend)

The app works out of the box using the mock backend service. No additional setup is required. Sample data is automatically loaded when the app starts.

### Sample Credentials

**Student Account:**
- Email: `student@example.com`
- Password: `password123`

**Owner Account:**
- Email: `owner@example.com`
- Password: `password123`

**Note**: These are demo credentials. The mock service accepts any password for these emails.

## Firebase Setup (Optional)

To use Firebase instead of the mock backend:

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use an existing one

2. **Add Android App**
   - Click "Add app" → Android
   - Download `google-services.json`
   - Place it in `android/app/`

3. **Add iOS App**
   - Click "Add app" → iOS
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

4. **Enable Firebase Services**
   - Authentication: Enable Email/Password
   - Firestore: Create database in production/test mode
   - Storage: Enable for images

5. **Update Firebase Service**
   - Uncomment Firebase implementation in `lib/core/services/firebase_service.dart`
   - Replace mock service with Firebase service in providers

6. **Configure Firestore Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /hostels/{hostelId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     resource.data.ownerId == request.auth.uid;
    }
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
    }
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                     request.auth.uid == userId;
    }
  }
}
```

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/hostel_list_test.dart

# Run with coverage
flutter test --coverage
```

### Test Files Included

- `test/features/hostel_provider_test.dart` - Unit tests for hostel provider
- `test/widgets/hostel_card_test.dart` - Widget test for hostel card
- Additional tests can be found in the `test/` directory

## Building for Production

### Android

1. **Build APK**
```bash
flutter build apk --release
```

2. **Build App Bundle**
```bash
flutter build appbundle --release
```

The output will be in `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/`

### iOS

1. **Open Xcode**
```bash
open ios/Runner.xcworkspace
```

2. **Configure Signing**
   - Select your development team
   - Update bundle identifier if needed

3. **Build**
```bash
flutter build ios --release
```

## Environment Variables

For Firebase configuration, you can use environment variables or the configuration files mentioned above.

### Example `.env` file (if using flutter_dotenv)

```
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
```

## API Documentation (Mock Backend)

The mock backend service implements the following methods:

### Authentication
- `signIn(email, password)` - Sign in user
- `signUp({email, password, name, role, phoneNumber})` - Register new user
- `signOut()` - Sign out current user

### Hostels
- `getHostels({city, minPrice, maxPrice, amenities, sortBy, page, limit})` - Get filtered hostels
- `getHostelById(hostelId)` - Get hostel details
- `searchHostels(query)` - Search hostels by name/city
- `createHostel({...})` - Owner: Create new hostel
- `updateHostel(hostel)` - Owner: Update hostel

### Bookings
- `createBooking({hostelId, userId, roomType, startDate, endDate, amount})` - Create booking
- `getUserBookings(userId)` - Get user's bookings
- `cancelBooking(bookingId)` - Cancel booking

### Reviews
- `createReview({hostelId, userId, userName, rating, comment})` - Add review
- `getHostelReviews(hostelId)` - Get hostel reviews

### Favorites
- `toggleFavorite(hostelId, userId)` - Add/remove favorite
- `isFavorite(hostelId, userId)` - Check if favorite

## Payment Integration (TODO)

The app includes a placeholder for payment integration. To integrate real payments:

1. **Stripe Integration**
   - Add `stripe_payment` or `flutter_stripe` package
   - Implement payment intent creation
   - Handle payment confirmation
   - Update `BookingScreen` with real payment flow

2. **PayPal Integration**
   - Add PayPal SDK
   - Implement payment flow
   - Handle payment callbacks

## Owner Verification & KYC

To implement real owner verification:

1. **Document Upload**
   - Add image picker functionality (already included)
   - Upload to Firebase Storage or backend
   - Store document references in user profile

2. **Admin Review**
   - Admin dashboard shows pending verifications
   - Admin can approve/reject with comments
   - Send notifications to owners

## CI/CD Setup (GitHub Actions Example)

A sample workflow is provided in `.github/workflows/` (if added). To use:

1. Enable GitHub Actions in your repository
2. Update the workflow file with your signing configuration
3. Push to trigger builds

## Troubleshooting

### Common Issues

1. **Build errors after cloning**
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **iOS build issues**
   - Run `pod install` in `ios/` directory
   - Update CocoaPods: `sudo gem install cocoapods`

3. **Android build issues**
   - Check Android SDK version in `android/app/build.gradle`
   - Ensure minimum SDK is 21 or higher

## Code Style

The project uses `flutter_lints` for code analysis. Run:

```bash
flutter analyze
```

To fix issues automatically (where possible):

```bash
dart fix --apply
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Check the documentation
- Review the code comments for implementation details

## Future Enhancements

- [ ] Real payment integration (Stripe/PayPal)
- [ ] Push notifications (FCM)
- [ ] Real-time messaging
- [ ] Advanced search filters
- [ ] Map view for hostels
- [ ] Social sharing
- [ ] In-app chat
- [ ] Document verification system
- [ ] Multi-language support (complete Urdu translation)
- [ ] Dark mode

## Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- Material Design for UI guidelines
- Firebase for backend services (optional)

---

**Note**: This is a demo application. For production use, ensure proper security measures, real payment integration, and comprehensive testing.

