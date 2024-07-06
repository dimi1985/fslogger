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
      id: map['id'] as int?,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : DateTime.now(),
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      aircraftId: (map['aircraftId'] as num?)?.toInt() ?? 0,
      departureAirport: map['departureAirport'] as String? ?? 'Unknown',
      arrivalAirport: map['arrivalAirport'] as String? ?? 'Unknown',
      remarks: map['remarks'] as String?,
      route: map['route'] as String?,
      routeDistance: (map['routeDistance'] as num?)?.toDouble(),
    );
  }
}
