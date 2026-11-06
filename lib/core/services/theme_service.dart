import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service for managing app preferences (theme, onboarding, recent searches).
///
/// It is a lazy singleton so the legacy `ThemeService()` call sites keep
/// working while the theme mode stays reactive for `GetMaterialApp`.
class ThemeService extends GetxService {
  ThemeService._()
    : themeMode = RxString((GetStorage().read(_key) as String?) ?? 'dark');

  static final ThemeService _instance = ThemeService._();

  factory ThemeService() => _instance;

  final RxString themeMode;
  final _box = GetStorage();
  static const String _key = 'theme_mode';

  /// Current saved theme mode (`dark`, `light` or `system`).
  String getThemeMode() => themeMode.value;

  /// Reactive [ThemeMode] for [GetMaterialApp].
  ThemeMode get materialThemeMode {
    switch (themeMode.value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  /// Save theme mode and notify listeners.
  Future<void> setThemeMode(String mode) async {
    themeMode.value = mode;
    await _box.write(_key, mode);
    Get.changeThemeMode(materialThemeMode);
  }

  /// Check if onboarding was completed.
  bool isOnboardingCompleted() {
    return _box.read('onboarding_completed') ?? false;
  }

  /// Mark onboarding as completed.
  Future<void> completeOnboarding() async {
    await _box.write('onboarding_completed', true);
  }

  /// Get recent searches.
  List<String> getRecentSearches() {
    final data = _box.read('recent_searches');
    if (data is List) {
      return data.cast<String>().take(10).toList();
    }
    return [];
  }

  /// Add a recent search.
  void addRecentSearch(String query) {
    final searches = getRecentSearches();
    searches.remove(query);
    searches.insert(0, query);
    _box.write('recent_searches', searches.take(10).toList());
  }

  /// Clear recent searches.
  void clearRecentSearches() {
    _box.remove('recent_searches');
  }
}
