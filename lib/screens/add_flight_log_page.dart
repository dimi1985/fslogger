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

  const AddFlightLogPage({super.key, this.lastFlightLog});

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

  @override
  void initState() {
    super.initState();
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
          _departureAirportController.text = widget.lastFlightLog?.arrivalAirport ?? 'Last Destination';
        }
      });
    }
  }

  void _calculateEstimatedTime() {
    if (_aircraft != null) {
      double routeDistance =
          double.tryParse(_routeDistanceController.text) ?? 0.0;
      _estimatedFlightTime = routeDistance / _aircraft!.normalCruiseSpeed;
      print('Estimated Flight Time: $_estimatedFlightTime hours');
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
    print('Flight Log Saved: Duration $durationInMinutes minutes');
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
      appBar: AppBar(
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
                  Text(localizations?.translate('aircraft_type') ??
                      'Aircraft: ${_aircraft?.type ?? 'Loading...'}'),
                  Text(localizations?.translate('last_destination') ??
                      'Last Destination: ${widget.lastFlightLog?.arrivalAirport ?? 'Loading...'}'),
                  Text(localizations?.translate('date') ??
                      'Date: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now())}'),
                ],
              ),
            if (_isDynamic && _isFlightStarted)
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
                              AppLocalizations.of(context)?.translate(
                                      'current_time', {
                                    'time':
                                        DateFormat('HH:mm').format(_currentTime)
                                  }) ??
                                  'Current Time: ${DateFormat('HH:mm').format(_currentTime)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AppLocalizations.of(context)?.translate(
                                      'elapsed_time', {
                                    'duration':
                                        (_flightDuration ~/ 60).toString()
                                  }) ??
                                  'Elapsed Time: ${_flightDuration ~/ 60} minutes',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
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
                ],
              ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (!_isDynamic)
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
