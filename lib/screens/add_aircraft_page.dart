// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/aircraft.dart';

class AddAircraftPage extends StatefulWidget {
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
  final AircraftDatabaseHelper _databaseHelper = AircraftDatabaseHelper();

  void _saveAircraft() async {
    if (_formKey.currentState!.validate()) {
      final aircraft = Aircraft(
        type: _typeController.text,
        rateOfClimb: double.parse(_rateOfClimbController.text),
        maxSpeed: double.parse(_maxSpeedController.text),
        normalCruiseSpeed: double.parse(_normalCruiseSpeedController.text),
        maxTakeoffWeight: double.parse(_maxTakeoffWeightController.text),
        operatingWeight: double.parse(_operatingWeightController.text),
        emptyWeight: double.parse(_emptyWeightController.text),
        fuelCapacity: double.parse(_fuelCapacityController.text),
        payloadUseful: double.parse(_payloadUsefulController.text),
        payloadWithFullFuel: double.parse(_payloadWithFullFuelController.text),
        maxPayload: double.parse(_maxPayloadController.text),
        serviceCeiling: double.parse(_serviceCeilingController.text),
        takeoffDistance: double.parse(_takeoffDistanceController.text),
        balancedFieldLength: double.parse(_balancedFieldLengthController.text),
        landingDistance: double.parse(_landingDistanceController.text),
        range: double.parse(_rangeController.text),
        maxCrosswindComponent: double.parse(_maxCrosswindController.text),
        maxTailwindComponent: double.parse(_maxTailwindController.text),
        maxWindGusts: double.parse(_maxWindGustsController.text),
      );

      await _databaseHelper.insertAircraft(aircraft);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Aircraft'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _typeController,
                  decoration:
                      const InputDecoration(labelText: 'Type of Aircraft'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the type of aircraft';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _rateOfClimbController,
                  decoration: const InputDecoration(
                      labelText: 'Rate of Climb (feet per minute)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the rate of climb';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxSpeedController,
                  decoration:
                      const InputDecoration(labelText: 'Max Speed (knots)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the max speed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _normalCruiseSpeedController,
                  decoration: const InputDecoration(
                      labelText: 'Normal Cruise Speed (knots)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the normal cruise speed';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxTakeoffWeightController,
                  decoration: const InputDecoration(
                      labelText: 'Max Takeoff Weight (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the max takeoff weight';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _operatingWeightController,
                  decoration: const InputDecoration(
                      labelText: 'Operating Weight (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the operating weight';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emptyWeightController,
                  decoration:
                      const InputDecoration(labelText: 'Empty Weight (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the empty weight';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fuelCapacityController,
                  decoration: const InputDecoration(
                      labelText: 'Fuel Capacity (gallons)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the fuel capacity';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _payloadUsefulController,
                  decoration: const InputDecoration(
                      labelText: 'Payload Useful (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the useful payload';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _payloadWithFullFuelController,
                  decoration: const InputDecoration(
                      labelText: 'Payload With Full Fuel (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the payload with full fuel';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxPayloadController,
                  decoration:
                      const InputDecoration(labelText: 'Max Payload (pounds)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the max payload';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _serviceCeilingController,
                  decoration: const InputDecoration(
                      labelText: 'Service Ceiling (feet)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the service ceiling';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _takeoffDistanceController,
                  decoration: const InputDecoration(
                      labelText: 'Takeoff Distance (feet)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the takeoff distance';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _balancedFieldLengthController,
                  decoration: const InputDecoration(
                      labelText: 'Balanced Field Length (feet)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the balanced field length';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _landingDistanceController,
                  decoration: const InputDecoration(
                      labelText: 'Landing Distance (feet)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the landing distance';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _rangeController,
                  decoration: const InputDecoration(
                      labelText: 'Range (nautical miles)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the range';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxCrosswindController,
                  decoration: const InputDecoration(
                      labelText: 'Maximum Crosswind (knots)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the maximum crosswind';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxTailwindController,
                  decoration: const InputDecoration(
                      labelText: 'Maximum Tailwind (knots)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the maximum tailwind';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _maxWindGustsController,
                  decoration:
                      const InputDecoration(labelText: 'Maximum Wind (knots)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the maximum wind';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAircraft,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
