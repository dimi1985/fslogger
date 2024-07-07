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
        _takeoffStatus =
            AppLocalizations.of(context)?.translate('fetch_weather_failed') ??
                'Failed to fetch weather data.';
      });
    }
  }

  String _determineTakeoffStatus(Map<String, dynamic> metarData) {
    final windSpeed = metarData['wind_speed']['value'];
    const maxCrosswindComponent = 15;
    _windDifference = windSpeed - maxCrosswindComponent;

    if (windSpeed <= maxCrosswindComponent) {
      return AppLocalizations.of(context)?.translate('weather_suitable') ??
          'Weather is suitable for takeoff.';
    } else {
      return '${AppLocalizations.of(context)?.translate('weather_not_suitable') ?? "Weather is not suitable for takeoff. Reason:"} Wind is $_windDifference knots above normal aircraft procedures.';
    }
  }

  String? _calculateEstimatedCalmTime(Map<String, dynamic> metarData) {
    final DateTime? observationTime =
        DateTime.tryParse(metarData['time']['dt']);
    if (observationTime != null) {
      final DateTime estimatedCalmTime = observationTime
          .add(const Duration(hours: 3)); // Assume calm within 3 hours
      final String localTime =
          DateFormat('HH:mm').format(estimatedCalmTime.toLocal());
      final String zuluTime = DateFormat('HH:mm').format(estimatedCalmTime);
      return '${AppLocalizations.of(context)?.translate('estimated_calm_time') ?? "Estimated calm time"}: $localTime local ($zuluTime Z)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
        title: Text(AppLocalizations.of(context)?.translate('flight_logs') ??
            'Flight Logs'),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: Center(
        child: _latestFlightLog != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade500
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                    ?.translate('latest_destination') ??
                                'Latest Destination',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _latestFlightLog!.arrivalAirport.toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70),
                          ),
                          SizedBox(height: 20),
                          if (_metarData != null)
                            WeatherStatusCard(
                              windSpeed: _metarData!['wind_speed']['value'],
                              windDifference: _windDifference,
                              takeoffStatus: _takeoffStatus!,
                              estimatedCalmTime: _estimatedCalmTime,
                              metarData:
                                  _metarData, // Ensure this is passed correctly
                              latestFlightLog:
                                  _latestFlightLog, // Ensure this is passed correctly
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Text(AppLocalizations.of(context)
                    ?.translate('no_flight_logs_available') ??
                'No flight logs available.'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  [
          BottomNavigationBarItem(
            icon:const Icon(Icons.add),
            label: AppLocalizations.of(context)
                    ?.translate('add') ??
                'Add',
          ),
          BottomNavigationBarItem(
            icon:const Icon(Icons.view_list),
            label: AppLocalizations.of(context)
                    ?.translate('view_logs') ??
                'View Logs',
          ),
          BottomNavigationBarItem(
            icon:const Icon(Icons.airplanemode_active),
            label: AppLocalizations.of(context)
                    ?.translate('aircraft') ??
                'Aircraft',
          ),
        ],
        // selectedItemColor: Colors.deepPurple,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  AddFlightLogPage(lastFlightLog: _latestFlightLog,)),
              ).then((_) => _fetchLatestFlightLog());
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ViewFlightLogsPage()),
              ).then((_) => _fetchLatestFlightLog());
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AircraftListPage()),
              );
              break;
          }
        },
      ),
    );
  }
}

class WeatherStatusCard extends StatelessWidget {
  final int windSpeed;
  final int? windDifference;
  final String takeoffStatus;
  final String? estimatedCalmTime;
  final Map<String, dynamic>? metarData;
  final FlightLog? latestFlightLog;

  const WeatherStatusCard({
    super.key,
    required this.windSpeed,
    this.windDifference,
    required this.takeoffStatus,
    this.estimatedCalmTime,
    this.metarData,
    this.latestFlightLog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${AppLocalizations.of(context)?.translate('wind_speed') ?? "Wind Speed"}: $windSpeed knots',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: windDifference != null && windDifference! > 0
                ? Colors.red[300]
                : Colors.green[300],
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: metarData != null && latestFlightLog != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedMetarPage(
                        airportCode: latestFlightLog!.arrivalAirport,
                        metarData: metarData!,
                      ),
                    ),
                  );
                }
              : null,
          child: Text(
            AppLocalizations.of(context)?.translate('view_detailed_metar') ??
                'View Detailed METAR',
            style: const TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                decoration: TextDecoration.underline),
          ),
        ),
        SizedBox(height: 10),
        Text(
          takeoffStatus,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        if (estimatedCalmTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              estimatedCalmTime!,
              style: TextStyle(fontSize: 16, color: Colors.yellowAccent),
            ),
          ),
      ],
    );
  }
}
