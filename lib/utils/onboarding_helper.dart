import 'package:shared_preferences/shared_preferences.dart';

class OnboardingHelper {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      // If there's an error, assume onboarding is not complete
      return false;
    }
  }

  /// Mark onboarding as complete
  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Reset onboarding (useful for testing)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompleteKey);
    } catch (e) {
      // Handle error silently
    }
  }
}

