import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:sky_tracker/app/routes/app_pages.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/app/themes/dark_theme.dart';
import 'package:sky_tracker/app/themes/light_theme.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/core/services/theme_service.dart';

final _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await GetStorage.init();

  // Initialize core services
  Get.put<FavoritesService>(FavoritesService(), permanent: true);

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    _logger.i('Environment variables loaded successfully.');
  } catch (e) {
    _logger.e('Failed to load .env file: $e');
  }

  runApp(const SkyTrackApp());
}

class SkyTrackApp extends StatelessWidget {
  const SkyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return GetMaterialApp(
      title: 'SkyTrack',
      debugShowCheckedModeBanner: false,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeService.materialThemeMode,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: AppPages.initialBinding,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 360),
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.2,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
