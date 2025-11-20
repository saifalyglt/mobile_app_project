import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/mock_backend_service.dart';

final backendServiceProvider = Provider<MockBackendService>((ref) {
  return MockBackendService();
});

final authServiceProvider = FutureProvider<void>((ref) async {
  final service = ref.read(backendServiceProvider);
  await service.initialize();
});

final currentUserProvider = StateProvider<AppUser?>((ref) {
  final service = ref.read(backendServiceProvider);
  return service.currentUser;
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  final service = ref.read(backendServiceProvider);
  return AuthNotifier(service, ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final MockBackendService _service;
  final Ref _ref;

  AuthNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      await _service.initialize();
      final user = _service.currentUser;
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.signIn(email, password);
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _service.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        phoneNumber: phoneNumber,
      );
      state = AsyncValue.data(user);
      _ref.read(currentUserProvider.notifier).state = user;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _service.signOut();
      state = const AsyncValue.data(null);
      _ref.read(currentUserProvider.notifier).state = null;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

