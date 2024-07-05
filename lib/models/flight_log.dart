class FlightLog {
  int? id;
  DateTime date;
  int duration;
  int aircraftId;
  String departureAirport;
  String arrivalAirport;
  String? remarks;
  String? route;
  double? routeDistance;

  FlightLog({
    this.id,
    required this.date,
    required this.duration,
    required this.aircraftId,
    required this.departureAirport,
    required this.arrivalAirport,
    this.remarks,
    this.route,
    this.routeDistance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration,
      'aircraftId': aircraftId,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'remarks': remarks,
      'route': route,
      'routeDistance': routeDistance,
    };
  }

  factory FlightLog.fromMap(Map<String, dynamic> map) {
    return FlightLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      duration: map['duration'],
      aircraftId: map['aircraftId'],
      departureAirport: map['departureAirport'],
      arrivalAirport: map['arrivalAirport'],
      remarks: map['remarks'],
      route: map['route'],
      routeDistance: map['routeDistance'],
    );
  }
}
