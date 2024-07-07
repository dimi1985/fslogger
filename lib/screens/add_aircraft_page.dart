// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/aircraft.dart';
import 'package:fslogger/screens/home_page.dart';
import 'package:fslogger/utils/applocalizations.dart'; // Ensure you have localization setup

class AddAircraftPage extends StatefulWidget {
  final Aircraft? aircraft;
  const AddAircraftPage({super.key, this.aircraft});

  @override
  _AddAircraftPageState createState() => _AddAircraftPageState();
}

class _AddAircraftPageState extends State<AddAircraftPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _rateOfClimbController = TextEditingController();
  final TextEditingController _maxSpeedController = TextEditingController();
  final TextEditingController _normalCruiseSpeedController =
      TextEditingController();
  final TextEditingController _maxTakeoffWeightController =
      TextEditingController();
  final TextEditingController _operatingWeightController =
      TextEditingController();
  final TextEditingController _emptyWeightController = TextEditingController();
  final TextEditingController _fuelCapacityController = TextEditingController();
  final TextEditingController _payloadUsefulController =
      TextEditingController();
  final TextEditingController _payloadWithFullFuelController =
      TextEditingController();
  final TextEditingController _maxPayloadController = TextEditingController();
  final TextEditingController _serviceCeilingController =
      TextEditingController();
  final TextEditingController _takeoffDistanceController =
      TextEditingController();
  final TextEditingController _balancedFieldLengthController =
      TextEditingController();
  final TextEditingController _landingDistanceController =
      TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  final TextEditingController _maxCrosswindController = TextEditingController();
  final TextEditingController _maxTailwindController = TextEditingController();
  final TextEditingController _maxWindGustsController = TextEditingController();
  bool isMilitary = false;

  final AircraftDatabaseHelper _databaseHelper = AircraftDatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.aircraft != null) {
      _typeController.text = widget.aircraft!.type;
      _rateOfClimbController.text = widget.aircraft!.rateOfClimb.toString();
      _maxSpeedController.text = widget.aircraft!.maxSpeed.toString();
      _normalCruiseSpeedController.text =
          widget.aircraft!.normalCruiseSpeed.toString();
      _maxTakeoffWeightController.text =
          widget.aircraft!.maxTakeoffWeight.toString();
      _operatingWeightController.text =
          widget.aircraft!.operatingWeight.toString();
      _emptyWeightController.text = widget.aircraft!.emptyWeight.toString();
      _fuelCapacityController.text = widget.aircraft!.fuelCapacity.toString();
      _payloadUsefulController.text = widget.aircraft!.payloadUseful.toString();
      _payloadWithFullFuelController.text =
          widget.aircraft!.payloadWithFullFuel.toString();
      _maxPayloadController.text = widget.aircraft!.maxPayload.toString();
      _serviceCeilingController.text =
          widget.aircraft!.serviceCeiling.toString();
      _takeoffDistanceController.text =
          widget.aircraft!.takeoffDistance.toString();
      _balancedFieldLengthController.text =
          widget.aircraft!.balancedFieldLength.toString();
      _landingDistanceController.text =
          widget.aircraft!.landingDistance.toString();
      _rangeController.text = widget.aircraft!.range.toString();
      _maxCrosswindController.text =
          widget.aircraft!.maxCrosswindComponent.toString();
      _maxTailwindController.text =
          widget.aircraft!.maxTailwindComponent.toString();
      _maxWindGustsController.text = widget.aircraft!.maxWindGusts.toString();
    }
  }

  void _saveAircraft() async {
    if (_formKey.currentState!.validate()) {
      final Aircraft aircraft = Aircraft(
        id: widget.aircraft?.id, // Use the existing ID if in edit mode
        type: _typeController.text,
        rateOfClimb: double.tryParse(_rateOfClimbController.text) ?? 0,
        maxSpeed: double.tryParse(_maxSpeedController.text) ?? 0,
        normalCruiseSpeed:
            double.tryParse(_normalCruiseSpeedController.text) ?? 0,
        maxTakeoffWeight:
            double.tryParse(_maxTakeoffWeightController.text) ?? 0,
        operatingWeight: double.tryParse(_operatingWeightController.text) ?? 0,
        emptyWeight: double.tryParse(_emptyWeightController.text) ?? 0,
        fuelCapacity: double.tryParse(_fuelCapacityController.text) ?? 0,
        payloadUseful: double.tryParse(_payloadUsefulController.text) ?? 0,
        payloadWithFullFuel:
            double.tryParse(_payloadWithFullFuelController.text) ?? 0,
        maxPayload: double.tryParse(_maxPayloadController.text) ?? 0,
        serviceCeiling: double.tryParse(_serviceCeilingController.text) ?? 0,
        takeoffDistance: double.tryParse(_takeoffDistanceController.text) ?? 0,
        balancedFieldLength:
            double.tryParse(_balancedFieldLengthController.text) ?? 0,
        landingDistance: double.tryParse(_landingDistanceController.text) ?? 0,
        range: double.tryParse(_rangeController.text) ?? 0,
        maxCrosswindComponent:
            double.tryParse(_maxCrosswindController.text) ?? 0,
        maxTailwindComponent: double.tryParse(_maxTailwindController.text) ?? 0,
        maxWindGusts: double.tryParse(_maxWindGustsController.text) ?? 0,
        isMilitary: isMilitary, hoursFlown: 0, parkingAirport: '',
      );

      // Call update if editing or insert if adding a new entry
      if (widget.aircraft != null) {
        await _databaseHelper.updateAircraft(aircraft);
      } else {
        await _databaseHelper.insertAircraft(aircraft);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        if (value) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(localizations?.translate('add_aircraft') ?? 'Add Aircraft'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(localizations?.translate('is_military') ??
                        'Is this aircraft military?'),
                    value: isMilitary,
                    onChanged: (bool value) {
                      setState(() {
                        isMilitary = value;
                      });
                    },
                    secondary: const Icon(Icons.flight_takeoff),
                  ),
                  // Type of Aircraft
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('type_of_aircraft_explanation') ??
                        'Enter the type of aircraft.'),
                  ),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('type_of_aircraft') ??
                                'Type of Aircraft'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_aircraft_type') ??
                            'Please enter the type of aircraft';
                      }
                      return null;
                    },
                  ),
                  // Rate of Climb
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                        localizations?.translate('rate_of_climb_explanation') ??
                            'Enter the rate of climb in feet per minute.'),
                  ),
                  TextFormField(
                    controller: _rateOfClimbController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('rate_of_climb') ??
                            'Rate of Climb (feet per minute)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_rate_of_climb') ??
                            'Please enter the rate of climb';
                      }
                      return null;
                    },
                  ),
                  // Max Speed
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_speed_explanation') ??
                        'Enter the maximum speed of the aircraft in knots.'),
                  ),
                  TextFormField(
                    controller: _maxSpeedController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('max_speed') ??
                            'Max Speed (knots)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.translate('enter_max_speed') ??
                            'Please enter the max speed';
                      }
                      return null;
                    },
                  ),
                  // Normal Cruise Speed
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('normal_cruise_speed_explanation') ??
                        'Enter the normal cruise speed of the aircraft in knots.'),
                  ),
                  TextFormField(
                    controller: _normalCruiseSpeedController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('normal_cruise_speed') ??
                                'Normal Cruise Speed (knots)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_normal_cruise_speed') ??
                            'Please enter the normal cruise speed';
                      }
                      return null;
                    },
                  ),
                  // Max Takeoff Weight
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_takeoff_weight_explanation') ??
                        'Enter the maximum takeoff weight of the aircraft in pounds.'),
                  ),
                  TextFormField(
                    controller: _maxTakeoffWeightController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('max_takeoff_weight') ??
                                'Max Takeoff Weight (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_max_takeoff_weight') ??
                            'Please enter the max takeoff weight';
                      }
                      return null;
                    },
                  ),
                  // Operating Weight
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('operating_weight_explanation') ??
                        'Enter the operating weight of the aircraft in pounds.'),
                  ),
                  TextFormField(
                    controller: _operatingWeightController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('operating_weight') ??
                                'Operating Weight (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_operating_weight') ??
                            'Please enter the operating weight';
                      }
                      return null;
                    },
                  ),
                  // Empty Weight
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('empty_weight_explanation') ??
                        'Enter the empty weight of the aircraft in pounds.'),
                  ),
                  TextFormField(
                    controller: _emptyWeightController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('empty_weight') ??
                            'Empty Weight (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.translate('enter_empty_weight') ??
                            'Please enter the empty weight';
                      }
                      return null;
                    },
                  ),
                  // Fuel Capacity
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('fuel_capacity_explanation') ??
                        'Enter the fuel capacity of the aircraft in gallons.'),
                  ),
                  TextFormField(
                    controller: _fuelCapacityController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('fuel_capacity') ??
                            'Fuel Capacity (gallons)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_fuel_capacity') ??
                            'Please enter the fuel capacity';
                      }
                      return null;
                    },
                  ),
                  // Useful Payload
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('useful_payload_explanation') ??
                        'Enter the useful payload capacity of the aircraft in pounds.'),
                  ),
                  TextFormField(
                    controller: _payloadUsefulController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('payload_useful') ??
                            'Payload Useful (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_payload_useful') ??
                            'Please enter the useful payload';
                      }
                      return null;
                    },
                  ),
                  // Payload With Full Fuel
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('payload_full_fuel_explanation') ??
                        'Enter the payload with full fuel in pounds.'),
                  ),
                  TextFormField(
                    controller: _payloadWithFullFuelController,
                    decoration: InputDecoration(
                        labelText: localizations
                                ?.translate('payload_with_full_fuel') ??
                            'Payload With Full Fuel (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_payload_full_fuel') ??
                            'Please enter the payload with full fuel';
                      }
                      return null;
                    },
                  ),
                  // Max Payload
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_payload_explanation') ??
                        'Enter the maximum payload capacity of the aircraft in pounds.'),
                  ),
                  TextFormField(
                    controller: _maxPayloadController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('max_payload') ??
                            'Max Payload (pounds)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.translate('enter_max_payload') ??
                            'Please enter the max payload';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('service_ceiling_explanation') ??
                        'Enter the maximum operating altitude of the aircraft in feet.'),
                  ),
                  TextFormField(
                    controller: _serviceCeilingController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('service_ceiling') ??
                                'Service Ceiling (feet)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_service_ceiling') ??
                            'Please enter the service ceiling';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('takeoff_distance_explanation') ??
                        'Enter the required distance for takeoff in feet.'),
                  ),
                  TextFormField(
                    controller: _takeoffDistanceController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('takeoff_distance') ??
                                'Takeoff Distance (feet)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_takeoff_distance') ??
                            'Please enter the takeoff distance';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('balanced_field_length_explanation') ??
                        'Enter the balanced field length which is the required runway length in feet.'),
                  ),
                  TextFormField(
                    controller: _balancedFieldLengthController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('balanced_field_length') ??
                                'Balanced Field Length (feet)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_balanced_field_length') ??
                            'Please enter the balanced field length';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('landing_distance_explanation') ??
                        'Enter the required distance for safe landing in feet.'),
                  ),
                  TextFormField(
                    controller: _landingDistanceController,
                    decoration: InputDecoration(
                        labelText:
                            localizations?.translate('landing_distance') ??
                                'Landing Distance (feet)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_landing_distance') ??
                            'Please enter the landing distance';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations?.translate('range_explanation') ??
                        'Enter the maximum range of the aircraft in nautical miles.'),
                  ),
                  TextFormField(
                    controller: _rangeController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('range') ??
                            'Range (nautical miles)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.translate('enter_range') ??
                            'Please enter the range';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_crosswind_explanation') ??
                        'Enter the maximum allowable crosswind component for takeoff and landing in knots.'),
                  ),
                  TextFormField(
                    controller: _maxCrosswindController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('max_crosswind') ??
                            'Maximum Crosswind (knots)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_max_crosswind') ??
                            'Please enter the maximum crosswind';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_tailwind_explanation') ??
                        'Enter the maximum allowable tailwind component for takeoff and landing in knots.'),
                  ),
                  TextFormField(
                    controller: _maxTailwindController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('max_tailwind') ??
                            'Maximum Tailwind (knots)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.translate('enter_max_tailwind') ??
                            'Please enter the maximum tailwind';
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(localizations
                            ?.translate('max_wind_gusts_explanation') ??
                        'Enter the maximum wind gusts the aircraft can withstand during operations in knots.'),
                  ),
                  TextFormField(
                    controller: _maxWindGustsController,
                    decoration: InputDecoration(
                        labelText: localizations?.translate('max_wind_gusts') ??
                            'Maximum Wind (knots)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations
                                ?.translate('enter_max_wind_gusts') ??
                            'Please enter the maximum wind gusts';
                      }
                      return null;
                    },
                  ),

                  // More fields should follow the same pattern...
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveAircraft,
                    child: Text(localizations?.translate('save') ?? 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
