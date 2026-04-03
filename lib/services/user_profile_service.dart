import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service for persisting student profile data.
class UserProfileService extends ChangeNotifier {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const _nameKey = 'profile_name';
  static const _rollKey = 'profile_roll';
  static const _branchKey = 'profile_branch';
  static const _yearKey = 'profile_year';
  static const _phoneKey = 'profile_phone';
  static const _emailKey = 'profile_email';

  String _name = '';
  String _rollNumber = '';
  String _branch = '';
  String _year = '';
  String _phoneNumber = '';
  String _email = '';
  bool _loaded = false;

  String get name => _name;
  String get rollNumber => _rollNumber;
  String get branch => _branch;
  String get year => _year;
  String get phoneNumber => _phoneNumber;
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
    _branch = prefs.getString(_branchKey) ?? '';
    _year = prefs.getString(_yearKey) ?? '';
    _phoneNumber = prefs.getString(_phoneKey) ?? '';
    _email = prefs.getString(_emailKey) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String rollNumber,
    required String branch,
    required String year,
    required String phoneNumber,
    required String email,
  }) async {
    _name = name.trim();
    _rollNumber = rollNumber.trim();
    _branch = branch.trim();
    _year = year.trim();
    _phoneNumber = phoneNumber.trim();
    _email = email.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_rollKey, _rollNumber);
    await prefs.setString(_branchKey, _branch);
    await prefs.setString(_yearKey, _year);
    await prefs.setString(_phoneKey, _phoneNumber);
    await prefs.setString(_emailKey, _email);
    notifyListeners();
  }

  Future<void> signOut() async {
    _name = '';
    _rollNumber = '';
    _branch = '';
    _year = '';
    _phoneNumber = '';
    _email = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_rollKey);
    await prefs.remove(_branchKey);
    await prefs.remove(_yearKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
    notifyListeners();
  }
}
