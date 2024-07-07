// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fslogger/screens/add_aircraft_page.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:fslogger/utils/settings_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/models/aircraft.dart';
import 'package:provider/provider.dart';

class AddFlightLogPage extends StatefulWidget {
  final FlightLog? lastFlightLog;

  const AddFlightLogPage({super.key, required this.lastFlightLog});

  @override
  _AddFlightLogPageState createState() => _AddFlightLogPageState();
}

class _AddFlightLogPageState extends State<AddFlightLogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureAirportController =
      TextEditingController();
  final TextEditingController _arrivalAirportController =
      TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _routeDistanceController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final AircraftDatabaseHelper _aircraftDatabaseHelper =
      AircraftDatabaseHelper();

  bool _isDynamic = false;
  bool _isFlightStarted = false;
  bool _showTimeInfo = true;
  Timer? _flightTimer;
  DateTime? _flightStartTime;
  DateTime _currentTime = DateTime.now();
  int _flightDuration = 0;
  Aircraft? _aircraft;
  double _estimatedFlightTime = 0.0;
  List<String> checklistItems = [
    'Preflight Inspection Completed',
    'Fuel Check',
    'Weight and Balance Checked',
    'Flight Plan Filed',
    'Weather Briefing Completed',
  ];

  List<bool> checklistStatus = [];

  @override
  void initState() {
    super.initState();
    checklistStatus = List<bool>.filled(checklistItems.length, false);
    _isDynamic =
        Provider.of<SettingsModel>(context, listen: false).defaultDynamicMode;
    _loadAircraftDetails();
    if (widget.lastFlightLog != null) {
      _departureAirportController.text =
          widget.lastFlightLog?.arrivalAirport ?? 'Last Destination';
    }
  }

  void _loadAircraftDetails() async {
    final aircraftList = await _aircraftDatabaseHelper.getAllAircraft();
    if (aircraftList.isEmpty) {
      // Redirect user to add aircraft if none exist
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AddAircraftPage()),
        );
      });
    } else {
      setState(() {
        _aircraft = aircraftList.first;
        if (widget.lastFlightLog != null) {
          _departureAirportController.text =
              widget.lastFlightLog?.arrivalAirport ?? 'Last Destination';
        }
      });
    }
  }

  void _calculateEstimatedTime() {
    if (_aircraft != null) {
      double routeDistance =
          double.tryParse(_routeDistanceController.text) ?? 0.0;
      _estimatedFlightTime = routeDistance / _aircraft!.normalCruiseSpeed;
    }
  }

  void _startFlight() {
    setState(() {
      _flightStartTime = DateTime.now();
      _isFlightStarted = true;
      _calculateEstimatedTime();
      _flightTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _currentTime = DateTime.now();
          _flightDuration =
              _currentTime.difference(_flightStartTime!).inSeconds;
        });
      });
    });
  }

  void _endFlight() {
    _flightTimer?.cancel();
    int durationInMinutes =
        DateTime.now().difference(_flightStartTime!).inMinutes;

    setState(() {
      _isFlightStarted = false;
    });

    if (durationInMinutes > _estimatedFlightTime * 60) {
      durationInMinutes = (_estimatedFlightTime * 60).toInt();
    }

    final flightLog = FlightLog(
      date: _flightStartTime!,
      duration: durationInMinutes,
      aircraftId: _aircraft!.id!,
      departureAirport:
          widget.lastFlightLog?.arrivalAirport ?? 'Last Destination',
      arrivalAirport: _arrivalAirportController.text,
      remarks: '',
      route: _routeController.text,
      routeDistance: double.tryParse(_routeDistanceController.text) ?? 0.0,
    );

    _databaseHelper.insertFlightLog(flightLog);
  }

  void _toggleTimeInfo() {
    setState(() {
      _showTimeInfo = !_showTimeInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: _isFlightStarted
          ? null
          : AppBar(
              title: Text(_isDynamic
                  ? localizations?.translate('dynamic_flight_log') ??
                      'Dynamic Flight Log'
                  : localizations?.translate('static_flight_log') ??
                      'Static Flight Log'),
              actions: [
                Switch(
                  value: _isDynamic,
                  onChanged: (bool value) {
                    setState(() {
                      _isDynamic = value;
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isFlightStarted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${localizations?.translate('aircraft_type') ?? 'Aircraft'}: ${_aircraft?.type ?? 'Loading...'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                      height: 8), // Provides some spacing between the texts
                  Text(
                    '${localizations?.translate('last_destination') ?? 'Last Destination'}: ${widget.lastFlightLog?.arrivalAirport ?? 'Loading...'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                      height: 8), // Provides some spacing between the texts
                  Text(
                    '${Localizations.of(context, AppLocalizations)?.translate('date') ?? 'Date'}: '
                    '${DateFormat('d MMMM yyyy - HH:mm', 'el').format(DateTime.now())}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            if (_isDynamic && _isFlightStarted)
              SizedBox(
                height: _isFlightStarted ? 100 : 0,
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_showTimeInfo)
                      Column(
                        children: [
                          Text(
                            '${AppLocalizations.of(context)?.translate('current_time') ?? 'Current Time:'} ${DateFormat('HH:mm').format(_currentTime)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${AppLocalizations.of(context)?.translate('elapsed_time') ?? 'Elapsed Time:'} ${_flightDuration ~/ 60} ${AppLocalizations.of(context)?.translate('minutes') ?? 'minutes'}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Estimated Time: ${_estimatedFlightTime.toStringAsFixed(2)} hours'),
                        ],
                      ),
                    const Spacer(),
                    IconButton(
                        onPressed: _toggleTimeInfo,
                        icon: Icon(_showTimeInfo
                            ? Icons.remove_red_eye_outlined
                            : Icons.remove_red_eye_rounded))
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 400,
                  width: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: checklistItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CheckboxListTile(
                        title: Text(checklistItems[index]),
                        value: checklistStatus[index],
                        onChanged: (bool? value) {
                          setState(() {
                            checklistStatus[index] = value!;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (!_isDynamic || !_isFlightStarted)
                      TextFormField(
                        controller: _departureAirportController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('departure_airport') ??
                                    'Departure Airport'),
                        onChanged: (value) {
                          _departureAirportController.value = TextEditingValue(
                            text: value.toUpperCase(),
                            selection: _departureAirportController.selection,
                          );
                        },
                      ),
                    if (!_isDynamic || !_isFlightStarted)
                      TextFormField(
                        controller: _arrivalAirportController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('arrival_airport') ??
                                    'Arrival Airport'),
                        onChanged: (value) {
                          _arrivalAirportController.value = TextEditingValue(
                            text: value.toUpperCase(),
                            selection: _arrivalAirportController.selection,
                          );
                        },
                      ),
                    if (!_isDynamic || !_isFlightStarted)
                      TextFormField(
                        controller: _routeController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('route') ?? 'Route'),
                        onChanged: (value) {
                          _routeController.value = TextEditingValue(
                            text: value.toUpperCase(),
                            selection: _routeController.selection,
                          );
                        },
                      ),
                    if (!_isDynamic || !_isFlightStarted)
                      TextFormField(
                        controller: _routeDistanceController,
                        decoration: InputDecoration(
                            labelText:
                                localizations?.translate('route_distance') ??
                                    'Route Distance (nm)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _calculateEstimatedTime();
                        },
                      ),
                    if (!_isDynamic) // Only show duration field when not in dynamic mode
                      TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                            labelText: localizations?.translate('duration') ??
                                'Duration (minutes)'),
                        keyboardType: TextInputType.number,
                      ),
                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_isDynamic) {
                          if (_isFlightStarted) {
                            _endFlight();
                          } else {
                            _startFlight();
                          }
                        } else {
                          _saveStaticFlightLog();
                        }
                      },
                      child: Text(_isDynamic
                          ? (_isFlightStarted
                              ? AppLocalizations.of(context)
                                      ?.translate('end_flight') ??
                                  'End Flight'
                              : AppLocalizations.of(context)
                                      ?.translate('start_flight') ??
                                  'Start Flight')
                          : AppLocalizations.of(context)
                                  ?.translate('save_log') ??
                              'Save Log'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveStaticFlightLog() async {
    if (_formKey.currentState!.validate()) {
      final FlightLog flightLog = FlightLog(
        date: DateTime.now(), // Or another appropriate date
        duration: int.tryParse(_durationController.text) ?? 0,
        aircraftId: _aircraft!.id!,
        departureAirport: _departureAirportController.text.toUpperCase(),
        arrivalAirport: _arrivalAirportController.text.toUpperCase(),
        remarks: '', // Add any other necessary fields
        route: _routeController.text,
        routeDistance: double.tryParse(_routeDistanceController.text) ?? 0.0,
      );

      await _databaseHelper.insertFlightLog(flightLog);
    }
  }
}
