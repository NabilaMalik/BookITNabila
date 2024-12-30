class LoginRepository {
  // Mocked registered users
  final List<String> _registeredUsers = ['test@example.com', 'user@example.com'];

  Future<bool> isUserRegistered(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _registeredUsers.contains(email);
  }
}
