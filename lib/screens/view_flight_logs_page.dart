import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/models/flight_log.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:fslogger/utils/firebase_service.dart';
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

  Future<void> _deleteFlightLog(int id, String documentId) async {
    await _databaseHelper.deleteFlightLog(id); // Local database deletion
    await FirebaseService().deleteFlightLog(documentId); // Firebase deletion
    _fetchFlightLogs(); // Refresh the local list
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalizations.of(context)?.translate('delete_flight_log') ??
                'Delete Flight Log'),
        content: Text(AppLocalizations.of(context)
                ?.translate('delete_flight_log_confirmation') ??
            'Are you sure you want to delete this flight log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
                AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteFlightLog(id, id.toString());
              Navigator.of(context).pop(true);
            },
            child: Text(
                AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)?.translate('view_flight_logs') ??
                'View Flight Logs'),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    side: const BorderSide(
                        color: Colors.blueAccent, width: 1), // Blue border
                  ),
                  child: ListTile(
                    leading: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_takeoff,
                            color: Colors.blue), // Departure icon
                        SizedBox(width: 4), // Space between icons
                        Icon(Icons.flight_land,
                            color: Colors.green), // Arrival icon
                      ],
                    ),
                    title: Text(
                      '${_formatDateTime(flightLog.date)} - ${flightLog.departureAirport} to ${flightLog.arrivalAirport}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // Emphasizes title
                      ),
                    ),
                    subtitle: Text(
                      '${AppLocalizations.of(context)?.translate('duration') ?? 'Duration'}: ${flightLog.duration} ${AppLocalizations.of(context)?.translate('minutes') ?? 'minutes'}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]), // Subdued subtitle text
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _showDeleteConfirmationDialog(flightLog.id!),
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
