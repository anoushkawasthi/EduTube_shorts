import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/services/user_profile_service.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _profile = UserProfileService.instance;

  late TextEditingController _nameCtrl;
  late TextEditingController _rollCtrl;
  late TextEditingController _branchCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _profile.name);
    _rollCtrl = TextEditingController(text: _profile.rollNumber);
    _branchCtrl = TextEditingController(text: _profile.branch);
    _yearCtrl = TextEditingController(text: _profile.year);
    _phoneCtrl = TextEditingController(text: _profile.phoneNumber);
    _emailCtrl = TextEditingController(text: _profile.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    _branchCtrl.dispose();
    _yearCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim().toLowerCase();
    if (!email.endsWith('@thapar.edu')) {
      return 'Must be a @thapar.edu email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@thapar\.edu$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateRoll(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    return null;
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  String? _validateYear(String? value) {
    final yearText = (value ?? '').trim();
    if (yearText.isEmpty) return 'Year is required';
    final year = int.tryParse(yearText);
    if (year == null || year < 1 || year > 5) {
      return 'Enter a valid year (1-5)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit number';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await _profile.updateProfile(
      name: _nameCtrl.text,
      rollNumber: _rollCtrl.text,
      branch: _branchCtrl.text,
      year: _yearCtrl.text,
      phoneNumber: _phoneCtrl.text,
      email: _emailCtrl.text.toLowerCase(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Profile saved'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary800,
                      child: Text(
                        _nameCtrl.text.trim().isNotEmpty
                            ? _nameCtrl.text.trim()[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile.isSignedIn ? 'Signed in' : 'Not signed in',
                      style: TextStyle(
                        color: _profile.isSignedIn
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name
              _buildLabel('Full Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                validator: _validateName,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(
                  hint: 'e.g. Rahul Sharma',
                  icon: Icons.person_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Roll Number
              _buildLabel('Roll Number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _rollCtrl,
                validator: _validateRoll,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                decoration: _inputDecoration(
                  hint: 'e.g. 102203611',
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Branch
              _buildLabel('Branch'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _branchCtrl,
                validator: (value) => _validateRequired(value, 'Branch'),
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  hint: 'e.g. Computer Engineering',
                  icon: Icons.account_tree_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Year
              _buildLabel('Year'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _yearCtrl,
                validator: _validateYear,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  hint: 'e.g. 3',
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Phone
              _buildLabel('Phone Number'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  hint: 'e.g. 9876543210',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Email
              _buildLabel('Thapar Email'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hint: 'yourname@thapar.edu',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in with your @thapar.edu email to save your profile.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary800,
                    disabledBackgroundColor: AppColors.gray300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              // Sign out
              if (_profile.isSignedIn) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await _profile.signOut();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.accent600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: context.appColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.appColors.textHint),
      prefixIcon: Icon(icon, color: context.appColors.textMuted, size: 20),
      filled: true,
      fillColor: context.appColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: context.appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: context.appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary800, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
