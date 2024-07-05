// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/screens/add_flight_log_page.dart';
import 'package:fslogger/screens/aircraft_list_page.dart';
import 'package:fslogger/screens/view_flight_logs_page.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/utils/metar_service.dart';
import 'package:fslogger/screens/detailed_metar_page.dart'; // Import the detailed METAR page
import 'package:intl/intl.dart'; // For date formatting

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final MetarService _weatherService = MetarService();
  FlightLog? _latestFlightLog;
  Map<String, dynamic>? _metarData;
  String? _takeoffStatus;
  int? _windDifference;
  String? _estimatedCalmTime;

  @override
  void initState() {
    super.initState();
    _fetchLatestFlightLog();
  }

  Future<void> _fetchLatestFlightLog() async {
    final flightLogs = await _databaseHelper.getAllFlightLogs();
    if (flightLogs.isNotEmpty) {
      setState(() {
        _latestFlightLog = flightLogs.last;
      });
      _fetchWeather(_latestFlightLog!.arrivalAirport);
    }
  }

  Future<void> _fetchWeather(String airportCode) async {
    final metarData = await _weatherService.fetchWeather(airportCode);
    if (metarData != null) {
      setState(() {
        _metarData = metarData;
        _takeoffStatus = _determineTakeoffStatus(metarData);
        _estimatedCalmTime = _calculateEstimatedCalmTime(metarData);
      });
    } else {
      setState(() {
        _takeoffStatus = 'Failed to fetch weather data.';
      });
    }
  }

  String _determineTakeoffStatus(Map<String, dynamic> metarData) {
    final windSpeed = metarData['wind_speed']['value'];
    const maxCrosswindComponent = 15;

    _windDifference = windSpeed - maxCrosswindComponent;

    if (windSpeed <= maxCrosswindComponent) {
      return 'Weather is suitable for takeoff.';
    } else {
      return 'Weather is not suitable for takeoff. Reason: Wind is $_windDifference knots above normal aircraft procedures.';
    }
  }

  String? _calculateEstimatedCalmTime(Map<String, dynamic> metarData) {
    final DateTime now = DateTime.now().toUtc();
    final DateTime? observationTime =
        DateTime.tryParse(metarData['time']['dt']);
    if (observationTime != null) {
      final DateTime estimatedCalmTime = observationTime
          .add(const Duration(hours: 3)); // Assume calm within 3 hours
      final String localTime =
          DateFormat('HH:mm').format(estimatedCalmTime.toLocal());
      final String zuluTime = DateFormat('HH:mm').format(estimatedCalmTime);
      return 'Estimated calm time: $localTime local ($zuluTime Z)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFlightLogPage()),
              ).then((_) => _fetchLatestFlightLog());
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewFlightLogsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.airplanemode_active),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AircraftListPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _latestFlightLog != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Latest Destination',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_metarData != null &&
                            _metarData!['station_name'] != null)
                          Text(
                            _metarData!['station_name'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        Text(
                          _latestFlightLog!.arrivalAirport,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Wind Speed: ${_metarData != null ? _metarData!['wind_speed']['value'] : 'Loading...'} knots',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _windDifference != null &&
                                          _windDifference! > 0
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _metarData != null
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailedMetarPage(
                                            airportCode: _latestFlightLog!
                                                .arrivalAirport,
                                            metarData: _metarData!,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'View Detailed METAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_takeoffStatus != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              children: [
                                Text(
                                  _takeoffStatus!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _takeoffStatus ==
                                            'Weather is suitable for takeoff.'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                if (_estimatedCalmTime != null)
                                  Text(
                                    _estimatedCalmTime!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            : const Text('No flight logs available.'),
      ),
    );
  }
}
