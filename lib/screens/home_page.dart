import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/screens/add_flight_log_page.dart';
import 'package:fslogger/screens/aircraft_list_page.dart';
import 'package:fslogger/screens/settings_page.dart';
import 'package:fslogger/screens/view_flight_logs_page.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/utils/metar_service.dart';
import 'package:fslogger/screens/detailed_metar_page.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:intl/intl.dart';

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
        _takeoffStatus = AppLocalizations.of(context)?.translate('fetch_weather_failed') ?? 'Failed to fetch weather data.';
      });
    }
  }

  String _determineTakeoffStatus(Map<String, dynamic> metarData) {
    final windSpeed = metarData['wind_speed']['value'];
    const maxCrosswindComponent = 15;
    _windDifference = windSpeed - maxCrosswindComponent;

    if (windSpeed <= maxCrosswindComponent) {
      return AppLocalizations.of(context)?.translate('weather_suitable') ?? 'Weather is suitable for takeoff.';
    } else {
      return '${AppLocalizations.of(context)?.translate('weather_not_suitable') ?? "Weather is not suitable for takeoff. Reason:"} Wind is $_windDifference knots above normal aircraft procedures.';
    }
  }

  String? _calculateEstimatedCalmTime(Map<String, dynamic> metarData) {
    final DateTime? observationTime = DateTime.tryParse(metarData['time']['dt']);
    if (observationTime != null) {
      final DateTime estimatedCalmTime = observationTime.add(const Duration(hours: 3)); // Assume calm within 3 hours
      final String localTime = DateFormat('HH:mm').format(estimatedCalmTime.toLocal());
      final String zuluTime = DateFormat('HH:mm').format(estimatedCalmTime);
      return '${AppLocalizations.of(context)?.translate('estimated_calm_time') ?? "Estimated calm time"}: $localTime local ($zuluTime Z)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('flight_logs') ?? 'Flight Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFlightLogPage(lastFlightLog: _latestFlightLog)),
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
                MaterialPageRoute(builder: (context) => const AircraftListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _latestFlightLog != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.translate('latest_destination') ?? 'Latest Destination',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _latestFlightLog!.arrivalAirport.toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${AppLocalizations.of(context)?.translate('wind_speed') ?? "Wind Speed"}: ${_metarData != null ? _metarData!['wind_speed']['value'] : 'Loading...'} knots',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _windDifference != null && _windDifference! > 0 ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _metarData != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailedMetarPage(
                                          airportCode: _latestFlightLog!.arrivalAirport,
                                          metarData: _metarData!,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            child: Text(
                              AppLocalizations.of(context)?.translate('view_detailed_metar') ?? 'View Detailed METAR',
                              style: const TextStyle(fontSize: 16, color: Colors.blueAccent, decoration: TextDecoration.underline),
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _takeoffStatus == 'Weather is suitable for takeoff.' ? Colors.green : Colors.red),
                              ),
                              if (_estimatedCalmTime != null)
                                Text(
                                  _estimatedCalmTime!,
                                  style: TextStyle(fontSize: 16, color: Colors.orange.withOpacity(0.7)),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : Text(AppLocalizations.of(context)?.translate('no_flight_logs_available') ?? 'No flight logs available.'),
      ),
    );
  }
}
