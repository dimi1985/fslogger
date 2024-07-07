// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fslogger/screens/add_aircraft_page.dart';
import 'package:fslogger/screens/home_page.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:fslogger/utils/metar_service.dart';
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
  bool isClosedPattern = false;
  Timer? _flightTimer;
  DateTime? _flightStartTime;
  DateTime _currentTime = DateTime.now();
  int _flightDuration = 0;
  Aircraft? _aircraft;
  double _estimatedFlightTime = 0.0;
  List<String> checklistItems = [
    // Pre-flight Inspection
    'Preflight Inspection Completed',
    'Fuel Check',
    'Weight and Balance Checked',
    'Flight Plan Filed',
    'Weather Briefing Completed',

    // Before Takeoff
    'Before Takeoff - Flaps Set to Takeoff Position',
    'Before Takeoff - Landing Light On',
    'Before Takeoff - Line Up and Wait',

    // After Takeoff
    'After Takeoff - Gear Up (if retractable)',
    'After Takeoff - Climb Power Set',
    'Top of Climb (TOC) Reached',

    // Cruising
    'Cruising Altitude Reached',
    'Fuel Checks at Intervals',

    // Top of Descent (TOD)
    'Top of Descent (TOD) Initiated',

    // Descent
    'Descent Checks Completed',

    // Before Landing
    'Before Landing - Flaps Set for Landing',
    'Before Landing - Landing Gear Down (if retractable)',
    'Before Landing - Landing Light On',

    // After Landing
    'After Landing - Flaps Retracted',
    'After Landing - Landing Light Off',
    'After Landing - Transponder Standby',

    // Securing Aircraft
    'Aircraft Secured and Logs Completed'
  ];

  List<bool> checklistStatus = [];

  Map<String, dynamic>? departureMetar;
  Map<String, dynamic>? destinationMetar;
  bool keyboardIsOpen = false;

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

  void fetchMetarDataDep(String airportCode) async {
    var metarData = await MetarService().fetchWeather(airportCode);
    setState(() {
      departureMetar = metarData;
    });
  }

  void fetchMetarDataDes(String airportCode) async {
    var metarData = await MetarService().fetchWeather(airportCode);
    setState(() {
      destinationMetar = metarData;
    });
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

    final aircraft = Aircraft(
      type: _aircraft?.type ?? '',
      rateOfClimb: _aircraft?.rateOfClimb ?? 0,
      maxSpeed: _aircraft?.maxSpeed ?? 0,
      normalCruiseSpeed: _aircraft?.normalCruiseSpeed ?? 0,
      maxTakeoffWeight: _aircraft?.maxTakeoffWeight ?? 0,
      operatingWeight: _aircraft?.operatingWeight ?? 0,
      emptyWeight: _aircraft?.emptyWeight ?? 0,
      fuelCapacity: _aircraft?.fuelCapacity ?? 0,
      payloadUseful: _aircraft?.payloadUseful ?? 0,
      payloadWithFullFuel: _aircraft?.payloadWithFullFuel ?? 0,
      maxPayload: _aircraft?.maxPayload ?? 0,
      serviceCeiling: _aircraft?.serviceCeiling ?? 0,
      takeoffDistance: _aircraft?.takeoffDistance ?? 0,
      balancedFieldLength: _aircraft?.balancedFieldLength ?? 0,
      landingDistance: _aircraft?.landingDistance ?? 0,
      range: _aircraft?.range ?? 0,
      maxCrosswindComponent: _aircraft?.maxCrosswindComponent ?? 0,
      maxTailwindComponent: _aircraft?.maxTailwindComponent ?? 0,
      maxWindGusts: _aircraft?.maxWindGusts ?? 0,
      isMilitary: _aircraft?.isMilitary ?? false,
      hoursFlown: durationInMinutes.toDouble(),
      parkingAirport: _arrivalAirportController.text,
    );
   
    print('Aircraft updated : $aircraft');
    _databaseHelper.insertFlightLog(flightLog);
     _aircraftDatabaseHelper.updateAircraft(aircraft);
    Navigator.pop(context);
  }

  void _toggleTimeInfo() {
    setState(() {
      _showTimeInfo = !_showTimeInfo;
    });
  }

  bool isKeyboardOpen(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom != 0;
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    keyboardIsOpen = isKeyboardOpen(context);
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
        appBar: _isFlightStarted
            ? null
            : AppBar(
                title: Text(
                  _isDynamic
                      ? localizations?.translate('dynamic_flight_log') ??
                          'Dynamic Flight Log'
                      : localizations?.translate('static_flight_log') ??
                          'Static Flight Log',
                  style: const TextStyle(
                      color: Colors
                          .white), // Optional: Adjust text color for better contrast
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.blueGrey
                      ], // Example colors, adjust as needed
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(
                        8), // Gives some padding around the switch
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color of the container
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset:
                              const Offset(0, 1), // Changes position of shadow
                        ),
                      ],
                    ),
                    child: Switch(
                      value: _isDynamic,
                      onChanged: (bool value) {
                        setState(() {
                          _isDynamic = value;
                        });
                      },
                      activeTrackColor: Colors.blue[300],
                      activeColor: Colors.blue[800],
                    ),
                  ),
                ],
                elevation: 4, // Elevates AppBar, casting a small shadow
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16), // Rounded bottom corners
                  ),
                ),
              ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_isFlightStarted)
                Visibility(
                  visible: !keyboardIsOpen,
                  child: Card(
                    elevation: 2, // Adds a subtle shadow
                    margin:
                        const EdgeInsets.all(8), // Gives space around the card
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.airplanemode_active,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            '${localizations?.translate('aircraft_type') ?? 'Aircraft'}: ${_aircraft?.type ?? 'Loading...'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          tileColor: Colors.white,
                        ),
                        const Divider(), // Adds a subtle line between items
                        ListTile(
                          leading: Icon(Icons.location_on,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            '${localizations?.translate('last_destination') ?? 'Last Destination'}: ${widget.lastFlightLog?.arrivalAirport ?? 'Loading...'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          tileColor: Colors.white,
                        ),
                        const Divider(), // Continues to separate each section
                        ListTile(
                          leading: Icon(Icons.calendar_today,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            '${Localizations.of(context, AppLocalizations)?.translate('date') ?? 'Date'}: '
                            '${DateFormat('d MMMM yyyy - HH:mm', 'el').format(DateTime.now())}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          tileColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              if (!_isFlightStarted)
                Visibility(
                  visible: !keyboardIsOpen,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey.shade200, // Light background color for the tile
                      borderRadius: BorderRadius.circular(
                          10), // Rounded corners for a softer look
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(0, 2), // Shadow for some depth
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: Text(
                        localizations?.translate('closed_pattern') ??
                            'Closed Pattern Flight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .primaryColorDark, // Darker text for contrast
                        ),
                      ),
                      value: isClosedPattern,
                      onChanged: (bool value) {
                        setState(() {
                          isClosedPattern = value;
                        });
                      },
                      subtitle: Text(
                        localizations?.translate('toggle_closed_pattern') ??
                            'Toggle if this is a closed pattern flight.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .hintColor, // Subtle hint color for subtitles
                        ),
                      ),
                      activeColor: Theme.of(context)
                          .primaryColor, // Use the accent color for active state
                      activeTrackColor:
                          Theme.of(context).primaryColor.withOpacity(0.5),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade400,
                      controlAffinity: ListTileControlAffinity
                          .leading, // Switch on the left side
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              if (_isDynamic && _isFlightStarted)
                SizedBox(
                  height: _isFlightStarted ? 100 : 0,
                ),
              if (_isFlightStarted)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_showTimeInfo)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(
                                  right:
                                      10), // Adds space between the two columns
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)?.translate('current_time') ?? 'Current Time:'} ${DateFormat('HH:mm').format(_currentTime)}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${AppLocalizations.of(context)?.translate('elapsed_time') ?? 'Elapsed Time:'} ${_flightDuration ~/ 60} ${AppLocalizations.of(context)?.translate('minutes') ?? 'minutes'}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Estimated Time: ${_estimatedFlightTime.toStringAsFixed(2)} hours',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.deepPurple),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: _toggleTimeInfo,
                          icon: Icon(_showTimeInfo
                              ? Icons.visibility_off
                              : Icons.visibility),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MetarCard(
                              metarData: departureMetar,
                              title: 'Departure METAR'),
                        ),
                        Expanded(
                          child: MetarCard(
                              metarData: destinationMetar,
                              title: 'Destination METAR'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                    
                        if (!_isDynamic || !_isFlightStarted)
                          TextFormField(
                            controller: _departureAirportController,
                            decoration: InputDecoration(
                              labelText: localizations
                                      ?.translate('departure_airport') ??
                                  'Departure Airport',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.flight_takeoff),
                            ),
                            onChanged: (value) {
                              _departureAirportController.value =
                                  TextEditingValue(
                                text: value.toUpperCase(),
                                selection:
                                    _departureAirportController.selection,
                              );
                            },
                          ),
                      const SizedBox(height: 10), // Adds space between fields
                  
                        if (!_isDynamic || !_isFlightStarted)
                          TextFormField(
                            controller: _arrivalAirportController,
                            decoration: InputDecoration(
                              labelText:
                                  localizations?.translate('arrival_airport') ??
                                      'Arrival Airport',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.flight_land),
                            ),
                            onChanged: (value) {
                              _arrivalAirportController.value =
                                  TextEditingValue(
                                text: value.toUpperCase(),
                                selection: _arrivalAirportController.selection,
                              );
                            },
                          ),
                      const SizedBox(height: 10),
                     
                        if (!_isDynamic || !_isFlightStarted)
                          TextFormField(
                            controller: _routeController,
                            decoration: InputDecoration(
                              labelText:
                                  localizations?.translate('route') ?? 'Route',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.map),
                            ),
                            onChanged: (value) {
                              _routeController.value = TextEditingValue(
                                text: value.toUpperCase(),
                                selection: _routeController.selection,
                              );
                            },
                          ),
                      const SizedBox(height: 10),
                   
                        if (!_isDynamic || !_isFlightStarted)
                          TextFormField(
                            controller: _routeDistanceController,
                            decoration: InputDecoration(
                              labelText:
                                  localizations?.translate('route_distance') ??
                                      'Route Distance (nm)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.linear_scale),
                              suffixText: 'nm',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _calculateEstimatedTime();
                            },
                          ),
                      const SizedBox(height: 10),
                    
                        if (!_isDynamic) // Only show duration field when not in dynamic mode
                          TextFormField(
                            controller: _durationController,
                            decoration: InputDecoration(
                              labelText: localizations?.translate('duration') ??
                                  'Duration (minutes)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.timer),
                              suffixText: 'minutes',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                    
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              localizations?.translate('closed_pattern_info') ??
                                  'Closed Traffic Pattern Area',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            Text(
                              "${_departureAirportController.text} - ${localizations?.translate('same_as_departure') ?? 'Same as Departure'}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (_isDynamic) {
                            if (_isFlightStarted) {
                              _endFlight();
                            } else {
                              _startFlight();
                              fetchMetarDataDep(
                                widget.lastFlightLog?.arrivalAirport ?? '',
                              );
                              fetchMetarDataDes(
                                _arrivalAirportController.text,
                              );
                            }
                          } else {
                            _saveStaticFlightLog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(_isDynamic
                            ? (_isFlightStarted
                                ? localizations?.translate('end_flight') ??
                                    'End Flight'
                                : localizations?.translate('start_flight') ??
                                    'Start Flight')
                            : localizations?.translate('save_log') ??
                                'Save Log'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class MetarCard extends StatelessWidget {
  final Map<String, dynamic>? metarData;
  final String title;

  const MetarCard({super.key, this.metarData, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(metarData != null
                ? 'Temperature: ${metarData?['temperature']['value']}'
                : 'Loading...'),
            Text(metarData != null
                ? 'Wind: ${metarData?['wind_speed']['value']} knots'
                : 'Loading...'),
            // Add more METAR details as needed
          ],
        ),
      ),
    );
  }
}
