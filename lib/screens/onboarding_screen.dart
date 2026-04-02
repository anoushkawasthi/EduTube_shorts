import 'package:flutter/material.dart';
import 'package:edutube_shorts/services/auth_service.dart';
import 'package:edutube_shorts/screens/auth_gate.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.ondemand_video_rounded,
      title: 'Learn with short videos',
      subtitle: 'Fast and focused content to keep your learning momentum high.',
    ),
    _OnboardingItem(
      icon: Icons.swipe_vertical_rounded,
      title: 'Swipe vertically for videos',
      subtitle: 'Move up and down to explore videos inside the same topic.',
    ),
    _OnboardingItem(
      icon: Icons.swipe_left_rounded,
      title: 'Swipe horizontally for topics',
      subtitle:
          'Go left and right to switch topics without leaving the player.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    await AuthService.instance.setSeenOnboarding(true);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: colors.cardBg,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary800.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(item.icon,
                                color: AppColors.primary800, size: 42),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.heading,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: _currentPage == index ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary800
                          : colors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleGetStarted,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
