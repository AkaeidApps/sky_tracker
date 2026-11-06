import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_tracker/app/routes/app_routes.dart';
import 'package:sky_tracker/app/routes/main_shell.dart';
import 'package:sky_tracker/core/services/favorites_service.dart';
import 'package:sky_tracker/features/airports/presentation/pages/airport_explorer_page.dart';
import 'package:sky_tracker/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:sky_tracker/features/booking/presentation/pages/booking_search_page.dart';
import 'package:sky_tracker/features/booking/presentation/pages/passenger_info_page.dart';
import 'package:sky_tracker/features/booking/presentation/pages/seat_selection_page.dart';
import 'package:sky_tracker/features/favorites/presentation/pages/favorites_page.dart';
import 'package:sky_tracker/features/flight_details/presentation/pages/flight_details_page.dart';
import 'package:sky_tracker/features/flight_search/presentation/pages/flight_search_page.dart';
import 'package:sky_tracker/features/live_map/presentation/pages/live_map_page.dart';
import 'package:sky_tracker/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sky_tracker/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:sky_tracker/features/profile/presentation/pages/profile_page.dart';
import 'package:sky_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:sky_tracker/features/splash/presentation/pages/splash_page.dart';

/// Fade + subtle upward slide used for every pushed route.
class _FadeSlideTransition extends CustomTransition {
  _FadeSlideTransition();

  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class AppPages {
  static final CustomTransition _transition = _FadeSlideTransition();

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShell(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.flightSearch,
      page: () => const FlightSearchPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.flightDetails,
      page: () => const FlightDetailsPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.liveMap,
      page: () => const LiveMapPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.airportExplorer,
      page: () => const AirportExplorerPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    // Booking routes
    GetPage(
      name: AppRoutes.bookingSearch,
      page: () => const BookingSearchPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.seatSelection,
      page: () => const SeatSelectionPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.passengerInfo,
      page: () => const PassengerInfoPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
    GetPage(
      name: AppRoutes.bookingConfirmation,
      page: () => const BookingConfirmationPage(),
      customTransition: _transition,
      transitionDuration: const Duration(milliseconds: 380),
    ),
  ];

  static final initialBinding = BindingsBuilder(() {
    Get.put<FavoritesService>(FavoritesService(), permanent: true);
  });
}
