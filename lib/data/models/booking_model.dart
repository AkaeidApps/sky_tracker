/// Represents a seat on an aircraft.
class SeatModel {
  final String seatId;
  final String rowNumber;
  final String columnLetter;
  final SeatType seatType;
  final SeatStatus seatStatus;

  SeatModel({
    required this.seatId,
    required this.rowNumber,
    required this.columnLetter,
    this.seatType = SeatType.economy,
    this.seatStatus = SeatStatus.available,
  });

  /// Generate a seat ID like "1A", "12F"
  String get displayId => '$rowNumber$columnLetter';

  /// Price multiplier based on seat type
  double get priceMultiplier {
    switch (seatType) {
      case SeatType.first:
        return 3.0;
      case SeatType.business:
        return 2.0;
      case SeatType.premiumEconomy:
        return 1.5;
      case SeatType.economy:
        return 1.0;
      case SeatType.exitRow:
        return 1.3;
    }
  }

  /// Label for the seat type
  String get typeLabel {
    switch (seatType) {
      case SeatType.first:
        return 'First';
      case SeatType.business:
        return 'Business';
      case SeatType.premiumEconomy:
        return 'Premium';
      case SeatType.economy:
        return 'Economy';
      case SeatType.exitRow:
        return 'Exit Row';
    }
  }
}

enum SeatType {
  first,
  business,
  premiumEconomy,
  economy,
  exitRow,
}

enum SeatStatus {
  available,
  occupied,
  selected,
  blocked,
}

/// Represents a passenger for booking.
class PassengerModel {
  final String? id;
  String firstName;
  String lastName;
  String email;
  String phone;
  String dateOfBirth;
  String gender;
  String passportNumber;
  String passportExpiry;
  String nationality;

  PassengerModel({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth = '',
    this.gender = 'male',
    this.passportNumber = '',
    this.passportExpiry = '',
    this.nationality = '',
  });

  String get fullName => '$firstName $lastName';

  bool get isValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      dateOfBirth.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'passportNumber': passportNumber,
        'passportExpiry': passportExpiry,
        'nationality': nationality,
      };

  factory PassengerModel.fromJson(Map<String, dynamic> json) => PassengerModel(
        id: json['id'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        dateOfBirth: json['dateOfBirth'] ?? '',
        gender: json['gender'] ?? 'male',
        passportNumber: json['passportNumber'] ?? '',
        passportExpiry: json['passportExpiry'] ?? '',
        nationality: json['nationality'] ?? '',
      );
}

/// Represents a complete ticket booking.
class TicketBookingModel {
  final String? bookingId;
  final String flightNumber;
  final String airlineName;
  final String departureIata;
  final String arrivalIata;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String date;
  final List<String> selectedSeats;
  final List<PassengerModel> passengers;
  final double basePrice;
  final double totalPrice;
  final String bookingStatus;
  final DateTime? bookedAt;

  TicketBookingModel({
    this.bookingId,
    required this.flightNumber,
    required this.airlineName,
    required this.departureIata,
    required this.arrivalIata,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.date,
    required this.selectedSeats,
    required this.passengers,
    required this.basePrice,
    required this.totalPrice,
    this.bookingStatus = 'confirmed',
    this.bookedAt,
  });

  /// Generate a booking ID
  String get bookingCode =>
      bookingId ?? 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  /// Seat count
  int get seatCount => selectedSeats.length;

  /// Passenger count
  int get passengerCount => passengers.length;

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'bookingCode': bookingCode,
        'flightNumber': flightNumber,
        'airlineName': airlineName,
        'departureIata': departureIata,
        'arrivalIata': arrivalIata,
        'departureAirport': departureAirport,
        'arrivalAirport': arrivalAirport,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'date': date,
        'selectedSeats': selectedSeats,
        'passengers': passengers.map((p) => p.toJson()).toList(),
        'basePrice': basePrice,
        'totalPrice': totalPrice,
        'bookingStatus': bookingStatus,
        'bookedAt': bookedAt?.toIso8601String(),
      };

  factory TicketBookingModel.fromJson(Map<String, dynamic> json) =>
      TicketBookingModel(
        bookingId: json['bookingId'],
        flightNumber: json['flightNumber'] ?? '',
        airlineName: json['airlineName'] ?? '',
        departureIata: json['departureIata'] ?? '',
        arrivalIata: json['arrivalIata'] ?? '',
        departureAirport: json['departureAirport'] ?? '',
        arrivalAirport: json['arrivalAirport'] ?? '',
        departureTime: json['departureTime'] ?? '',
        arrivalTime: json['arrivalTime'] ?? '',
        date: json['date'] ?? '',
        selectedSeats: List<String>.from(json['selectedSeats'] ?? []),
        passengers: (json['passengers'] as List?)
                ?.map((p) => PassengerModel.fromJson(p))
                .toList() ??
            [],
        basePrice: (json['basePrice'] ?? 0).toDouble(),
        totalPrice: (json['totalPrice'] ?? 0).toDouble(),
        bookingStatus: json['bookingStatus'] ?? 'confirmed',
        bookedAt: json['bookedAt'] != null
            ? DateTime.parse(json['bookedAt'])
            : null,
      );
}

/// Flight search criteria for booking.
class FlightSearchCriteria {
  final String departureCity;
  final String arrivalCity;
  final DateTime date;
  final int adultCount;
  final int childCount;
  final int infantCount;
  final String cabinClass;

  FlightSearchCriteria({
    required this.departureCity,
    required this.arrivalCity,
    required this.date,
    this.adultCount = 1,
    this.childCount = 0,
    this.infantCount = 0,
    this.cabinClass = 'economy',
  });

  int get totalPassengers => adultCount + childCount + infantCount;

  Map<String, dynamic> toJson() => {
        'departureCity': departureCity,
        'arrivalCity': arrivalCity,
        'date': date.toIso8601String(),
        'adultCount': adultCount,
        'childCount': childCount,
        'infantCount': infantCount,
        'cabinClass': cabinClass,
      };
}
