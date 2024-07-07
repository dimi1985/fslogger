import 'package:flutter/material.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/aircraft.dart';
import 'package:fslogger/screens/add_aircraft_page.dart';
import 'package:fslogger/utils/applocalizations.dart';

class AircraftListPage extends StatefulWidget {
  const AircraftListPage({super.key});

  @override
  _AircraftListPageState createState() => _AircraftListPageState();
}

class _AircraftListPageState extends State<AircraftListPage> {
  final AircraftDatabaseHelper _databaseHelper = AircraftDatabaseHelper();
  List<Aircraft> _aircraftList = [];

  @override
  void initState() {
    super.initState();
    _fetchAircraftList();
  }

  Future<void> _fetchAircraftList() async {
    final aircraftList = await _databaseHelper.getAllAircraft();
    setState(() {
      _aircraftList = aircraftList;
    });
  }

  void _navigateToAddEditAircraftPage({Aircraft? aircraft}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddAircraftPage(aircraft: aircraft)),
    );
    _fetchAircraftList();
  }

  void _deleteAircraft(int aircraftId) async {
    await _databaseHelper.deleteAircraft(aircraftId);
    _fetchAircraftList();
  }

  void _showDeleteConfirmationDialog(Aircraft aircraft) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              AppLocalizations.of(context)?.translate('confirm_delete') ??
                  'Confirm Delete'),
          content: Text(
              '${AppLocalizations.of(context)?.translate('are_you_sure_delete') ?? 'Are you sure you want to delete'} ${aircraft.type}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.translate('cancel') ??
                  'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAircraft(aircraft.id!);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)?.translate('delete') ??
                  'Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(localizations?.translate('aircraft_list') ?? 'Aircraft List'),
        backgroundColor: Colors.indigo[400], // Stylish color for the app bar
      ),
      body: _aircraftList.isEmpty
          ? Center(
              child: Text(localizations?.translate('no_aircraft_found') ??
                  'No aircraft found. Please add an aircraft.'))
          : ListView.separated(
              itemCount: _aircraftList.length,
              itemBuilder: (context, index) {
                final aircraft = _aircraftList[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[200],
                      child: Text(aircraft.type[0],
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(aircraft.type),
                    subtitle: Column(
                      children: [
                        Text(
                            '${localizations?.translate('total_flight_hours') ?? "Total Flight Hours"}: ${aircraft.hoursFlown} hours'),
                        Text(
                            '${localizations?.translate('current_parking') ?? "Current Parking"}: ${aircraft.parkingAirport}')
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToAddEditAircraftPage(
                              aircraft: aircraft),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(aircraft),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () => _navigateToAddEditAircraftPage(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
