import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Provider gérant l'état global de l'application
class AppProvider extends ChangeNotifier {
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isDarkMode = false;

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;


  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await StorageService.instance.init();
      _isOnboardingComplete = await StorageService.instance.isOnboardingComplete();
    } catch (e) {
      debugPrint('AppProvider init error: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }


  Future<void> completeOnboarding() async {
    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    notifyListeners();
  }


  Future<void> resetOnboarding() async {
    await StorageService.instance.setOnboardingComplete(false);
    _isOnboardingComplete = false;
    notifyListeners();
  }


  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
