import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import '../models/flight_log.dart';
import 'package:fslogger/utils/applocalizations.dart'; // Import your localization utility

class ViewFlightLogsPage extends StatefulWidget {
  @override
  _ViewFlightLogsPageState createState() => _ViewFlightLogsPageState();
}

class _ViewFlightLogsPageState extends State<ViewFlightLogsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<FlightLog> _flightLogs = [];
  int _totalFlightMinutes = 0;

  @override
  void initState() {
    super.initState();
    _fetchFlightLogs();
  }

  Future<void> _fetchFlightLogs() async {
    final flightLogs = await _databaseHelper.getAllFlightLogs();
    setState(() {
      _flightLogs = flightLogs;
      _totalFlightMinutes = _calculateTotalFlightMinutes(flightLogs);
    });
  }

  int _calculateTotalFlightMinutes(List<FlightLog> flightLogs) {
    return flightLogs.fold(0, (sum, log) => sum + log.duration);
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> _deleteFlightLog(int id) async {
    await _databaseHelper.deleteFlightLog(id);
    _fetchFlightLogs();
  }

  void _showDeleteConfirmationDialog(int id) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations?.translate('delete_flight_log') ?? 'Delete Flight Log'),
        content: Text(localizations?.translate('delete_flight_log_confirmation') ?? 'Are you sure you want to delete this flight log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteFlightLog(id);
              Navigator.of(context).pop();
            },
            child: Text(localizations?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('view_flight_logs') ?? 'View Flight Logs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${localizations?.translate('total_flight_hours') ?? 'Total Flight Hours'}: ${_formatDuration(_totalFlightMinutes)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _flightLogs.length,
              itemBuilder: (context, index) {
                final flightLog = _flightLogs[index];
                return ListTile(
                  title: Text('${flightLog.date.toLocal()} - ${flightLog.aircraftId}'),
                  subtitle: Text(
                      '${localizations?.translate('duration') ?? 'Duration'}: ${flightLog.duration} ${localizations?.translate('minutes') ?? 'minutes'}\n${localizations?.translate('departure') ?? 'Departure'}: ${flightLog.departureAirport}\n${localizations?.translate('arrival') ?? 'Arrival'}: ${flightLog.arrivalAirport}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(flightLog.remarks ?? ''),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmationDialog(flightLog.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
