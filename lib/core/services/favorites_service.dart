import 'package:get_storage/get_storage.dart';

/// Service for managing favorite flights using local storage.
class FavoritesService {
  final _box = GetStorage();
  static const String _key = 'favorites';

  /// Get all favorite flight IDs.
  List<String> getFavoriteFlightIds() {
    final data = _box.read(_key);
    if (data is List) {
      return data.cast<String>();
    }
    return [];
  }

  /// Check if a flight is favorited.
  bool isFavorite(String flightId) {
    return getFavoriteFlightIds().contains(flightId);
  }

  /// Add a flight to favorites.
  void addFavorite(String flightId) {
    final favorites = getFavoriteFlightIds();
    if (!favorites.contains(flightId)) {
      favorites.add(flightId);
      _box.write(_key, favorites);
    }
  }

  /// Remove a flight from favorites.
  void removeFavorite(String flightId) {
    final favorites = getFavoriteFlightIds();
    favorites.remove(flightId);
    _box.write(_key, favorites);
  }

  /// Toggle favorite status.
  void toggleFavorite(String flightId) {
    if (isFavorite(flightId)) {
      removeFavorite(flightId);
    } else {
      addFavorite(flightId);
    }
  }

  /// Clear all favorites.
  void clearFavorites() {
    _box.remove(_key);
  }
}
