import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/models/aircraft.dart';

class AddFlightLogPage extends StatefulWidget {
  const AddFlightLogPage({super.key});

  @override
  _AddFlightLogPageState createState() => _AddFlightLogPageState();
}

class _AddFlightLogPageState extends State<AddFlightLogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _departureAirportController = TextEditingController();
  final TextEditingController _arrivalAirportController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _routeDistanceController = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AircraftDatabaseHelper _aircraftDatabaseHelper = AircraftDatabaseHelper();

  bool _isDynamic = false;
  bool _isFlightStarted = false;
  bool _showTimer = true;
  Timer? _flightTimer;
  DateTime? _flightStartTime;
  int _flightDuration = 0;
  int? _flightLogId;
  Aircraft? _aircraft;
  double _estimatedFlightTime = 0.0;
  List<String> _routeWaypoints = [];
  Map<String, bool> _reportedStages = {};

  @override
  void initState() {
    super.initState();
    _loadAircraftDetails();
  }

  void _loadAircraftDetails() async {
    final aircraftList = await _aircraftDatabaseHelper.getAllAircraft();
    if (aircraftList.isNotEmpty) {
      setState(() {
        _aircraft = aircraftList.first;
      });
    }
  }

  void _calculateEstimatedTime() {
    if (_aircraft != null) {
      double routeDistance = double.tryParse(_routeDistanceController.text) ?? 0.0;
      _estimatedFlightTime = routeDistance / _aircraft!.normalCruiseSpeed;
      print('Estimated Flight Time: $_estimatedFlightTime hours');
    }
  }

  void _startFlight() async {
    setState(() {
      _flightDuration = 0;
      _isFlightStarted = true;
      _routeWaypoints = _routeController.text.split(RegExp(r'[\s,]+')).map((e) => e.trim()).toList();
      _calculateEstimatedTime();
      _flightStartTime = DateTime.now();
      _flightTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _flightDuration = DateTime.now().difference(_flightStartTime!).inSeconds;
        });
      });
    });

    final flightLog = FlightLog(
      date: DateTime.now(),
      duration: 0,
      aircraftId: _aircraft!.id!,
      departureAirport: _departureAirportController.text.toUpperCase(),
      arrivalAirport: _arrivalAirportController.text.toUpperCase(),
      remarks: '',
      route: _routeController.text,
      routeDistance: double.tryParse(_routeDistanceController.text) ?? 0.0,
    );

    _flightLogId = await _databaseHelper.insertFlightLog(flightLog);
    print('Flight Log Started: $_flightLogId');
  }

  void _endFlight() async {
    _flightTimer?.cancel();

    bool confirmCancel = false;
    if (_flightDuration < _estimatedFlightTime * 3600) {
      confirmCancel = await _showCancelConfirmationDialog();
    }

    if (confirmCancel) {
      _flightDuration = (_estimatedFlightTime * 3600).toInt();
    }

    setState(() {
      _isFlightStarted = false;
    });

    if (_flightLogId != null) {
      final flightLog = FlightLog(
        id: _flightLogId,
        date: _flightStartTime!,
        duration: _flightDuration ~/ 60, // Store duration in minutes
        aircraftId: _aircraft!.id!,
        departureAirport: _departureAirportController.text.toUpperCase(),
        arrivalAirport: _arrivalAirportController.text.toUpperCase(),
        remarks: '',
        route: _routeController.text,
        routeDistance: double.tryParse(_routeDistanceController.text) ?? 0.0,
      );

      await _databaseHelper.updateFlightLog(flightLog);
      print('Flight Log Ended: $_flightLogId');
    }
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Flight Cancellation'),
              content: const Text('Are you sure you want to cancel the flight?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Finish Flight'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Cancel Flight'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Resume Flight'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _reportStage(String stage) {
    setState(() {
      _reportedStages[stage] = true;
    });

    print('Reported Stage: $stage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flight Log'),
        actions: [
          Switch(
            value: _isDynamic,
            onChanged: (value) {
              setState(() {
                _isDynamic = value;
                _dateController.clear();
                _durationController.clear();
                _routeController.clear();
                _routeDistanceController.clear();
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isDynamic && _isFlightStarted
            ? Container(
                color: Colors.blueGrey[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_showTimer)
                          Text(
                            'Flight Duration: ${_flightDuration ~/ 60}:${(_flightDuration % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        IconButton(
                          icon: Icon(_showTimer ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _showTimer = !_showTimer;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Estimated Time: ${_estimatedFlightTime.toStringAsFixed(2)} hours',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _endFlight,
                      child: const Text('End Flight'),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildFlightStage('Taxiing'),
                          _buildFlightStage('Airborne'),
                          _buildFlightStage('Cruise Altitude'),
                          for (var waypoint in _routeWaypoints) _buildFlightStage(waypoint, isWaypoint: true),
                          _buildFlightStage('Descent'),
                          _buildFlightStage('Approach'),
                          _buildFlightStage('Final'),
                          _buildFlightStage('Landed'),
                          _buildFlightStage('Parked'),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isDynamic)
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Date'),
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (date != null) {
                              _dateController.text = date.toIso8601String();
                            }
                          },
                        ),
                      if (!_isDynamic)
                        TextFormField(
                          controller: _durationController,
                          decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                          keyboardType: TextInputType.number,
                        ),
                      TextFormField(
                        controller: _departureAirportController,
                        decoration: const InputDecoration(labelText: 'Departure Airport'),
                        onChanged: (text) {
                          setState(() {
                            _departureAirportController.text = text.toUpperCase();
                            _departureAirportController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
                          });
                        },
                      ),
                      TextFormField(
                        controller: _arrivalAirportController,
                        decoration: const InputDecoration(labelText: 'Arrival Airport'),
                        onChanged: (text) {
                          setState(() {
                            _arrivalAirportController.text = text.toUpperCase();
                            _arrivalAirportController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
                          });
                        },
                      ),
                      TextFormField(
                        controller: _routeController,
                        decoration: const InputDecoration(labelText: 'Route'),
                      ),
                      TextFormField(
                        controller: _routeDistanceController,
                        decoration: const InputDecoration(labelText: 'Route Distance (nm)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isFlightStarted ? _endFlight : _startFlight,
                        child: Text(_isFlightStarted ? 'End Flight' : 'Start Flight'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFlightStage(String stage, {bool isWaypoint = false}) {
    return ListTile(
      title: Text(stage, style: TextStyle(fontSize: isWaypoint ? 16 : 20, fontWeight: FontWeight.bold)),
      trailing: ElevatedButton(
        onPressed: () {
          _reportStage(stage);
        },
        child: _reportedStages[stage] == true ? const Icon(Icons.check) : const Text('Report'),
      ),
      tileColor: _reportedStages[stage] == true ? Colors.grey[300] : null,
    );
  }
}
