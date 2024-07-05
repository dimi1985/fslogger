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
      id: map['id'],
      type: map['type'],
      rateOfClimb: map['rateOfClimb'],
      maxSpeed: map['maxSpeed'],
      normalCruiseSpeed: map['normalCruiseSpeed'],
      maxTakeoffWeight: map['maxTakeoffWeight'],
      operatingWeight: map['operatingWeight'],
      emptyWeight: map['emptyWeight'],
      fuelCapacity: map['fuelCapacity'],
      payloadUseful: map['payloadUseful'],
      payloadWithFullFuel: map['payloadWithFullFuel'],
      maxPayload: map['maxPayload'],
      serviceCeiling: map['serviceCeiling'],
      takeoffDistance: map['takeoffDistance'],
      balancedFieldLength: map['balancedFieldLength'],
      landingDistance: map['landingDistance'],
      range: map['range'],
      maxCrosswindComponent: map['maxCrosswindComponent'],
      maxTailwindComponent: map['maxTailwindComponent'],
      maxWindGusts: map['maxWindGusts'],
    );
  }
}
