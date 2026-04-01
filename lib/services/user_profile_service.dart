import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service for persisting student profile data.
class UserProfileService extends ChangeNotifier {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const _nameKey = 'profile_name';
  static const _rollKey = 'profile_roll';
  static const _emailKey = 'profile_email';

  String _name = '';
  String _rollNumber = '';
  String _email = '';
  bool _loaded = false;

  String get name => _name;
  String get rollNumber => _rollNumber;
  String get email => _email;
  bool get isSignedIn => _email.isNotEmpty;

  /// Display name — falls back to email prefix or "Student".
  String get displayName {
    if (_name.isNotEmpty) return _name;
    if (_email.isNotEmpty) return _email.split('@').first;
    return 'Student';
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? '';
    _rollNumber = prefs.getString(_rollKey) ?? '';
    _email = prefs.getString(_emailKey) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String rollNumber,
    required String email,
  }) async {
    _name = name.trim();
    _rollNumber = rollNumber.trim();
    _email = email.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_rollKey, _rollNumber);
    await prefs.setString(_emailKey, _email);
    notifyListeners();
  }

  Future<void> signOut() async {
    _name = '';
    _rollNumber = '';
    _email = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_rollKey);
    await prefs.remove(_emailKey);
    notifyListeners();
  }
}
