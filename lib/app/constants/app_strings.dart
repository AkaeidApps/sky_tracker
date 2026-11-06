/// App-wide string constants.
class AppStrings {
  AppStrings._();

  static const String appName = 'SkyTrack';
  static const String appTagline = 'Live Flight Tracker';

  // Onboarding
  static const String onboardingTitle1 = 'Track Flights in Real-Time';
  static const String onboardingSubtitle1 =
      'Monitor any flight around the world with live status updates and accurate data.';
  static const String onboardingTitle2 = 'Explore Airports Worldwide';
  static const String onboardingSubtitle2 =
      'Discover airports, view arrivals and departures, and plan your journeys.';
  static const String onboardingTitle3 = 'Never Miss a Flight Update';
  static const String onboardingSubtitle3 =
      'Get notified about flight status changes, delays, and gate information.';
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  // Authentication
  static const String welcome = 'Welcome to SkyTrack';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String haveAccount = 'Already have an account? ';
  static const String guestMode = 'Continue as Guest';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';

  // Home
  static const String home = 'Home';
  static const String explore = 'Explore';
  static const String liveMap = 'Live Map';
  static const String favorites = 'Favorites';
  static const String profile = 'Profile';
  static const String searchFlight = 'Search flight number or airport...';
  static const String recentSearches = 'Recent Searches';
  static const String liveFlights = 'Live Flights';
  static const String popularAirlines = 'Popular Airlines';
  static const String popularAirports = 'Popular Airports';
  static const String quickActions = 'Quick Actions';
  static const String greeting = 'Good {time}, {name}';

  // Flight Search
  static const String flightSearch = 'Flight Search';
  static const String searchByFlightNumber = 'Search by Flight Number';
  static const String filterByAirline = 'Filter by Airline';
  static const String filterByDeparture = 'Filter by Departure';
  static const String filterByArrival = 'Filter by Arrival';
  static const String filterByDate = 'Filter by Date';
  static const String filterByStatus = 'Filter by Status';
  static const String searchHistory = 'Search History';
  static const String noResults = 'No results found';
  static const String clearHistory = 'Clear History';

  // Flight Details
  static const String flightDetails = 'Flight Details';
  static const String departure = 'Departure';
  static const String arrival = 'Arrival';
  static const String flightStatus = 'Flight Status';
  static const String aircraft = 'Aircraft';
  static const String terminal = 'Terminal';
  static const String gate = 'Gate';
  static const String scheduledDeparture = 'Scheduled Departure';
  static const String scheduledArrival = 'Scheduled Arrival';
  static const String estimatedDeparture = 'Estimated Departure';
  static const String estimatedArrival = 'Estimated Arrival';
  static const String actualDeparture = 'Actual Departure';
  static const String actualArrival = 'Actual Arrival';
  static const String duration = 'Duration';
  static const String refreshFlight = 'Refresh Flight';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';

  // Airport
  static const String airportExplorer = 'Airport Explorer';
  static const String airportDetails = 'Airport Details';
  static const String airportSearch = 'Search airports...';
  static const String city = 'City';
  static const String country = 'Country';

  // Airline
  static const String airlineExplorer = 'Airline Explorer';
  static const String airlineSearch = 'Search airlines...';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String notificationPreferences = 'Notification Preferences';

  // Settings
  static const String settings = 'Settings';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemMode = 'System';
  static const String language = 'Language';
  static const String cacheManagement = 'Cache Management';
  static const String clearCache = 'Clear Cache';
  static const String apiStatus = 'API Connection';
  static const String connected = 'Connected';
  static const String notConnected = 'Not Connected';
  static const String about = 'About SkyTrack';
  static const String privacyPolicy = 'Privacy Policy';
  static const String logout = 'Logout';
  static const String version = 'Version';

  // Errors
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String apiError = 'API error. Please try again later.';
  static const String noInternet = 'No internet connection';
  static const String retry = 'Retry';
  static const String tryAgain = 'Try Again';
  static const String noData = 'No data available';
  static const String emptyFavorites = 'No favorites yet';
  static const String emptyMessage =
      'Start adding flights or airports to your favorites.';

  // Flight Status
  static const String scheduled = 'Scheduled';
  static const String inAir = 'In Air';
  static const String landed = 'Landed';
  static const String estimated = 'Estimated';
  static const String delayed = 'Delayed';
  static const String cancelled = 'Cancelled';
  static const String diverted = 'Diverted';
  static const String unknown = 'Unknown';
}
