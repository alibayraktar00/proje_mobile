import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserModel?>((ref) {
  return UserProfileNotifier(ref.watch(authServiceProvider));
});

class UserProfileNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  UserProfileNotifier(this._authService) : super(null);

  Future<void> loadUserProfile(String uid) async {
    try {
      final user = await _authService.getUserData(uid);
      state = user;
    } catch (e) {
      state = null;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _authService.updateUserProfile(user);
      state = user;
    } catch (e) {
      // Handle error
    }
  }

  void clearProfile() {
    state = null;
  }
}

