import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sky_tracker/data/models/airport_model.dart';

/// Loads and searches the bundled worldwide airport directory.
///
/// The dataset (29k+ airports, 236 countries) ships with the app so the
/// explorer works offline and without burning API credits.
class AirportService {
  AirportService._();

  static final AirportService _instance = AirportService._();

  factory AirportService() => _instance;

  static const String assetPath = 'assets/data/airports.json';

  List<AirportModel>? _airports;
  Map<String, String> _countries = const {};

  bool get isLoaded => _airports != null;

  List<AirportModel> get airports => _airports ?? const [];

  int get countryCount => _countries.length;

  int get iataCount => airports.where((a) => a.hasIata).length;

  /// Loads the dataset once and caches it for the rest of the session.
  Future<List<AirportModel>> load() async {
    final cached = _airports;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final countries = (decoded['countries'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value.toString()));
    final rows = decoded['airports'] as List<dynamic>;

    final airports = <AirportModel>[];
    for (final row in rows) {
      if (row is List) {
        airports.add(
          AirportModel.fromCompactList(row, countries: countries),
        );
      }
    }

    _countries = countries;
    _airports = airports;
    return airports;
  }

  /// Ranked search across codes, names, cities and countries.
  ///
  /// Exact code matches come first, then code/name prefix matches, then any
  /// remaining substring matches.
  List<AirportModel> search(
    String query, {
    List<AirportModel>? source,
  }) {
    final all = source ?? airports;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;

    final exact = <AirportModel>[];
    final prefix = <AirportModel>[];
    final contains = <AirportModel>[];

    for (final airport in all) {
      final iata = airport.iata.toLowerCase();
      final icao = airport.icao.toLowerCase();
      final name = airport.name.toLowerCase();
      final city = airport.city.toLowerCase();
      final country = airport.countryName.toLowerCase();

      if (iata == q || icao == q) {
        exact.add(airport);
      } else if ((iata.isNotEmpty && iata.startsWith(q)) ||
          icao.startsWith(q) ||
          name.startsWith(q) ||
          city.startsWith(q)) {
        prefix.add(airport);
      } else if (name.contains(q) ||
          city.contains(q) ||
          country.contains(q)) {
        contains.add(airport);
      }
    }

    int byName(AirportModel a, AirportModel b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    exact.sort(byName);
    prefix.sort(byName);
    contains.sort(byName);

    return [...exact, ...prefix, ...contains];
  }
}
