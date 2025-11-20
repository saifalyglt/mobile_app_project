import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/hostel_list/screens/hostel_list_screen.dart';
import '../../features/hostel_detail/screens/hostel_detail_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/owner/screens/owner_dashboard_screen.dart';
import '../../features/owner/screens/add_hostel_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSignIn = state.matchedLocation == '/sign-in';
      final isSignUp = state.matchedLocation == '/sign-up';

      // If not logged in and not on auth screens, redirect to sign-in
      if (!isLoggedIn && !isOnboarding && !isSignIn && !isSignUp) {
        return '/sign-in';
      }

      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && (isSignIn || isSignUp || isOnboarding)) {
        final user = authState.value;
        if (user?.isAdmin == true) {
          return '/admin';
        } else if (user?.isOwner == true) {
          return '/owner';
        }
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/hostels',
        builder: (context, state) {
          final city = state.uri.queryParameters['city'];
          return HostelListScreen(city: city);
        },
      ),
      GoRoute(
        path: '/hostel/:id',
        builder: (context, state) {
          final hostelId = state.pathParameters['id']!;
          return HostelDetailScreen(hostelId: hostelId);
        },
      ),
      GoRoute(
        path: '/booking/:hostelId',
        builder: (context, state) {
          final hostelId = state.pathParameters['hostelId']!;
          return BookingScreen(hostelId: hostelId);
        },
      ),
      GoRoute(
        path: '/booking-confirmation/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/owner',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/owner/add-hostel',
        builder: (context, state) => const AddHostelScreen(),
      ),
      GoRoute(
        path: '/owner/edit-hostel/:id',
        builder: (context, state) {
          final hostelId = state.pathParameters['id']!;
          return AddHostelScreen(hostelId: hostelId);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});

