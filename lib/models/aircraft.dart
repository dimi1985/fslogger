class Aircraft {
  int? id;
  String type;
  double rateOfClimb; // in feet per minute
  double maxSpeed; // in knots
  double normalCruiseSpeed; // in knots
  double maxTakeoffWeight; // in pounds
  double operatingWeight; // in pounds
  double emptyWeight; // in pounds
  double fuelCapacity; // in gallons
  double payloadUseful; // in pounds
  double payloadWithFullFuel; // in pounds
  double maxPayload; // in pounds
  double serviceCeiling; // in feet
  double takeoffDistance; // in feet
  double balancedFieldLength; // in feet
  double landingDistance; // in feet
  double range; // in nautical miles
  double maxCrosswindComponent; // in knots
  double maxTailwindComponent; // in knots
  double maxWindGusts; // in knots

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
    );
  }
}
