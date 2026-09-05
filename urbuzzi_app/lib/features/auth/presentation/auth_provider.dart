import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth/user_role.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final currentUserRoleProvider = Provider<UserRole>((ref) {
  final userState = ref.watch(authControllerProvider);
  return userState.value?.role ?? UserRole.consulta;
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    
    try {
      final user = await _repository.fetchMe();
      if (user != null) {
        state = AsyncValue.data(user);
        return;
      }
    } catch (_) {}

    // Fallback para o email persistido
    if (savedEmail != null) {
      state = AsyncValue.data(User(id: 'local', name: savedEmail, email: savedEmail, roleStr: 'administrador'));
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.login(email, password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      
      state = AsyncValue.data(user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final user = await _repository.register(name, email, password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email);
      
      state = AsyncValue.data(user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _repository.resetPassword(token, newPassword);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
