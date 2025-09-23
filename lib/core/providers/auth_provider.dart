import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_data.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      await _authRepository.login(email, password);
      state = const AuthState.authenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(UserData userData) async {
    state = const AuthState.loading();
    try {
      await _authRepository.register(userData);
      state = const AuthState.registered();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() {
    state = const AuthState.initial();
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isRegistered;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isRegistered = false,
    this.error,
  });

  const AuthState.initial() : this();
  const AuthState.loading() : this(isLoading: true);
  const AuthState.authenticated() : this(isAuthenticated: true);
  const AuthState.registered() : this(isRegistered: true);
  const AuthState.error(String error) : this(error: error);
}