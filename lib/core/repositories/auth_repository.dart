import '../models/user_data.dart';

class AuthRepository {
  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }
    
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    // Simulate successful login
    // In a real app, this would make an API call
  }

  Future<void> register(UserData userData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock validation
    if (userData.fullName.isEmpty ||
        userData.email.isEmpty ||
        userData.password.isEmpty ||
        userData.organizationName.isEmpty) {
      throw Exception('All required fields must be filled');
    }
    
    if (!userData.email.contains('@')) {
      throw Exception('Invalid email format');
    }
    
    if (userData.password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    // Simulate successful registration
    // In a real app, this would make an API call
  }
}