import 'package:flutter/material.dart';
import 'package:fslogger/database/database_helper.dart';
import '../models/flight_log.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flight Log'),
        content: const Text('Are you sure you want to delete this flight log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteFlightLog(id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Flight Logs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Flight Hours: ${_formatDuration(_totalFlightMinutes)}',
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
                      'Duration: ${flightLog.duration} minutes\nDeparture: ${flightLog.departureAirport}\nArrival: ${flightLog.arrivalAirport}'),
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
