# Quick Setup Guide

## Prerequisites

1. **Install Flutter SDK**
   - Download from https://flutter.dev/docs/get-started/install
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to check installation

2. **Install Android Studio / Xcode** (for platform-specific development)
   - Android Studio: https://developer.android.com/studio
   - Xcode: Available on Mac App Store (for iOS development)

## Initial Setup

1. **Navigate to project directory**
   ```bash
   cd hostel_finder
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files** (IMPORTANT!)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   This generates the `.g.dart` files for JSON serialization. **You must run this before running the app!**

4. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS (Mac only)
   flutter run -d ios
   ```

## First Run

The app uses mock backend by default, so it will work immediately without any backend configuration.

### Sample Credentials

**Student Account:**
- Email: `student@example.com`
- Password: Any password (demo mode)

**Owner Account:**
- Email: `owner@example.com`
- Password: Any password (demo mode)

## Troubleshooting

### Issue: Build errors related to `.g.dart` files

**Solution:** Run build_runner to generate the files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Cannot find module errors

**Solution:** Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: iOS build fails

**Solution:**
```bash
cd ios
pod install
cd ..
flutter run
```

### Issue: Android build fails

**Solution:** 
- Check that Android SDK is installed
- Ensure minimum SDK version is 21 or higher
- Check `android/app/build.gradle` for configuration

## Next Steps

1. **Try the demo:** Browse hostels, make a booking, explore all features
2. **Set up Firebase** (optional): See README.md for Firebase setup instructions
3. **Customize:** Modify the theme, add your own sample data, etc.
4. **Test:** Run tests with `flutter test`

For more detailed information, see [README.md](README.md).

