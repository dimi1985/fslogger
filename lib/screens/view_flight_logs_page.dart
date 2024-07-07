import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:intl/intl.dart'; // Import the intl library

class ViewFlightLogsPage extends StatefulWidget {
  const ViewFlightLogsPage({super.key});

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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy - HH:mm').format(dateTime);
  }

  Future<void> _deleteFlightLog(int id) async {
    await _databaseHelper.deleteFlightLog(id);
    _fetchFlightLogs();
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('delete_flight_log') ?? 'Delete Flight Log'),
        content: Text(AppLocalizations.of(context)?.translate('delete_flight_log_confirmation') ?? 'Are you sure you want to delete this flight log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteFlightLog(id);
              Navigator.of(context).pop(true);
            },
            child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('view_flight_logs') ?? 'View Flight Logs'),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${AppLocalizations.of(context)?.translate('total_flight_hours') ?? 'Total Flight Hours'}: ${_formatDuration(_totalFlightMinutes)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _flightLogs.length,
              itemBuilder: (context, index) {
                final flightLog = _flightLogs[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.flight_takeoff, color: Theme.of(context).primaryColor),
                    title: Text('${_formatDateTime(flightLog.date)} - ${flightLog.departureAirport} to ${flightLog.arrivalAirport}'),
                    subtitle: Text('${AppLocalizations.of(context)?.translate('duration') ?? 'Duration'}: ${flightLog.duration} ${AppLocalizations.of(context)?.translate('minutes') ?? 'minutes'}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(flightLog.id!),
                    ),
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
