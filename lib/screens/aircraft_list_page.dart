import 'package:flutter/material.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/models/aircraft.dart';
import 'add_aircraft_page.dart';
import 'package:fslogger/utils/applocalizations.dart';  // Import your localization utility

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

  void _navigateToAddAircraftPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAircraftPage()),
    );
    _fetchAircraftList(); // Refresh the list after returning from AddAircraftPage
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('aircraft_list') ?? 'Aircraft List'),
      ),
      body: _aircraftList.isEmpty
          ? Center(child: Text(localizations?.translate('no_aircraft_found') ?? 'No aircraft found. Please add an aircraft.'))
          : ListView.builder(
              itemCount: _aircraftList.length,
              itemBuilder: (context, index) {
                final aircraft = _aircraftList[index];
                return ListTile(
                  title: Text(aircraft.type),
                  subtitle: Text('${localizations?.translate('max_speed') ?? "Max Speed"}: ${aircraft.maxSpeed} knots'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAircraftPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
