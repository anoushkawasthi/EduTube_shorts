import 'package:edutube_shorts/utils/local_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _seenOnboardingKey = 'seenOnboarding';
  static const String _userEmailKey = 'userEmail';
  static const String _userPasswordKey = 'userPassword';
  static const String _userNameKey = 'userName';

  Future<void> signUp(String email, String password) async {
    await LocalStorage.setString(_userEmailKey, email.trim().toLowerCase());
    await LocalStorage.setString(_userPasswordKey, password);
    await LocalStorage.setBool(_isLoggedInKey, false);
  }

  Future<bool> signIn(String email, String password) async {
    final savedEmail = await LocalStorage.getString(_userEmailKey);
    final savedPassword = await LocalStorage.getString(_userPasswordKey);

    final isValid =
        savedEmail == email.trim().toLowerCase() && savedPassword == password;
    if (isValid) {
      await LocalStorage.setBool(_isLoggedInKey, true);
    }
    return isValid;
  }

  Future<void> completeProfile(String name) async {
    await LocalStorage.setString(_userNameKey, name.trim());
    await LocalStorage.setBool(_isLoggedInKey, true);
  }

  Future<void> logout() async {
    await LocalStorage.setBool(_isLoggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    return LocalStorage.getBool(_isLoggedInKey);
  }

  Future<bool> hasSeenOnboarding() async {
    return LocalStorage.getBool(_seenOnboardingKey);
  }

  Future<void> setSeenOnboarding(bool value) async {
    await LocalStorage.setBool(_seenOnboardingKey, value);
  }

  Future<String> getUserEmail() async {
    return LocalStorage.getString(_userEmailKey);
  }

  Future<String> getUserName() async {
    return LocalStorage.getString(_userNameKey);
  }
}
