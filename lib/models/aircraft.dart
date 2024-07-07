class Aircraft {
  int? id;
  String type;
  double rateOfClimb;
  double maxSpeed;
  double normalCruiseSpeed;
  double maxTakeoffWeight;
  double operatingWeight;
  double emptyWeight;
  double fuelCapacity;
  double payloadUseful;
  double payloadWithFullFuel;
  double maxPayload;
  double serviceCeiling;
  double takeoffDistance;
  double balancedFieldLength;
  double landingDistance;
  double range;
  double maxCrosswindComponent;
  double maxTailwindComponent;
  double maxWindGusts;
  bool isMilitary; // Added to differentiate between military and civilian aircraft
  double hoursFlown; // Added to track total flight hours
  String parkingAirport; // Added to track current parking location

  Aircraft({
    this.id,
    required this.type,
    required this.rateOfClimb,
    required this.maxSpeed,
    required this.normalCruiseSpeed,
    required this.maxTakeoffWeight,
    required this.operatingWeight,
    required this.emptyWeight,
    required this.fuelCapacity,
    required this.payloadUseful,
    required this.payloadWithFullFuel,
    required this.maxPayload,
    required this.serviceCeiling,
    required this.takeoffDistance,
    required this.balancedFieldLength,
    required this.landingDistance,
    required this.range,
    required this.maxCrosswindComponent,
    required this.maxTailwindComponent,
    required this.maxWindGusts,
    required this.isMilitary,
    required this.hoursFlown,
    required this.parkingAirport,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'rateOfClimb': rateOfClimb,
      'maxSpeed': maxSpeed,
      'normalCruiseSpeed': normalCruiseSpeed,
      'maxTakeoffWeight': maxTakeoffWeight,
      'operatingWeight': operatingWeight,
      'emptyWeight': emptyWeight,
      'fuelCapacity': fuelCapacity,
      'payloadUseful': payloadUseful,
      'payloadWithFullFuel': payloadWithFullFuel,
      'maxPayload': maxPayload,
      'serviceCeiling': serviceCeiling,
      'takeoffDistance': takeoffDistance,
      'balancedFieldLength': balancedFieldLength,
      'landingDistance': landingDistance,
      'range': range,
      'maxCrosswindComponent': maxCrosswindComponent,
      'maxTailwindComponent': maxTailwindComponent,
      'maxWindGusts': maxWindGusts,
      'isMilitary': isMilitary ? 1 : 0,  // Convert boolean to integer
      'hoursFlown': hoursFlown,
      'parkingAirport': parkingAirport,
    };
  }

  factory Aircraft.fromMap(Map<String, dynamic> map) {
    return Aircraft(
      id: map['id'] as int?,
      type: map['type'] as String? ?? 'Unknown',
      rateOfClimb: (map['rateOfClimb'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (map['maxSpeed'] as num?)?.toDouble() ?? 0.0,
      normalCruiseSpeed: (map['normalCruiseSpeed'] as num?)?.toDouble() ?? 0.0,
      maxTakeoffWeight: (map['maxTakeoffWeight'] as num?)?.toDouble() ?? 0.0,
      operatingWeight: (map['operatingWeight'] as num?)?.toDouble() ?? 0.0,
      emptyWeight: (map['emptyWeight'] as num?)?.toDouble() ?? 0.0,
      fuelCapacity: (map['fuelCapacity'] as num?)?.toDouble() ?? 0.0,
      payloadUseful: (map['payloadUseful'] as num?)?.toDouble() ?? 0.0,
      payloadWithFullFuel: (map['payloadWithFullFuel'] as num?)?.toDouble() ?? 0.0,
      maxPayload: (map['maxPayload'] as num?)?.toDouble() ?? 0.0,
      serviceCeiling: (map['serviceCeiling'] as num?)?.toDouble() ?? 0.0,
      takeoffDistance: (map['takeoffDistance'] as num?)?.toDouble() ?? 0.0,
      balancedFieldLength: (map['balancedFieldLength'] as num?)?.toDouble() ?? 0.0,
      landingDistance: (map['landingDistance'] as num?)?.toDouble() ?? 0.0,
      range: (map['range'] as num?)?.toDouble() ?? 0.0,
      maxCrosswindComponent: (map['maxCrosswindComponent'] as num?)?.toDouble() ?? 0.0,
      maxTailwindComponent: (map['maxTailwindComponent'] as num?)?.toDouble() ?? 0.0,
      maxWindGusts: (map['maxWindGusts'] as num?)?.toDouble() ?? 0.0,
       isMilitary: map['isMilitary'] == 1,  // Convert integer to boolean
      hoursFlown: (map['hoursFlown'] as num?)?.toDouble() ?? 0.0,
      parkingAirport: map['parkingAirport'] as String? ?? 'Unknown',
    );
  }
}
