class LoginRepository {
  // Mocked registered users
  final List<String> _registeredUsers = ['B02', 'B03'];

  Future<bool> isUserRegistered(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return _registeredUsers.contains(email);
  }
}
