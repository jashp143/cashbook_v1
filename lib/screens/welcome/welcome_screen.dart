import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../config/theme.dart';
import '../../utils/onboarding_helper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onLanguageSelected(Locale locale) async {
    setState(() {
      _selectedLocale = locale;
    });

    // Update language provider
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.setLanguage(locale);

    // Mark onboarding as complete
    await OnboardingHelper.setOnboardingComplete();

    // Navigate to splash screen, which will then navigate to home
    if (mounted) {
      context.go('/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.black : AppTheme.white;
    final textColor = isDark ? AppTheme.white : AppTheme.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // App Logo
                  Image.asset(
                    'assets/khataVahi.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // Welcome Title
                  Text(
                    'Welcome to Khata Vahi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Your Personal Cashbook',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.7),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Language Selection Title
                  Text(
                    'Select Your Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Language Options
                  _buildLanguageOption(
                    context,
                    title: 'English',
                    locale: const Locale('en'),
                    isSelected: _selectedLocale?.languageCode == 'en',
                    onTap: () => _onLanguageSelected(const Locale('en')),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context,
                    title: 'हिंदी (Hindi)',
                    locale: const Locale('hi'),
                    isSelected: _selectedLocale?.languageCode == 'hi',
                    onTap: () => _onLanguageSelected(const Locale('hi')),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context,
                    title: 'ગુજરાતી (Gujarati)',
                    locale: const Locale('gu'),
                    isSelected: _selectedLocale?.languageCode == 'gu',
                    onTap: () => _onLanguageSelected(const Locale('gu')),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required Locale locale,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.white : AppTheme.black;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppTheme.white.withOpacity(0.15)
                  : AppTheme.black.withOpacity(0.1))
              : (isDark
                  ? AppTheme.white.withOpacity(0.05)
                  : AppTheme.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.white : AppTheme.black)
                : (isDark
                    ? AppTheme.white.withOpacity(0.2)
                    : AppTheme.black.withOpacity(0.2)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.language_rounded,
              color: isSelected
                  ? (isDark ? AppTheme.white : AppTheme.black)
                  : textColor.withOpacity(0.7),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? AppTheme.white : AppTheme.black)
                      : textColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? AppTheme.white : AppTheme.black,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

