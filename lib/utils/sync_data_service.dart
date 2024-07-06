import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/models/aircraft.dart';
import 'package:fslogger/models/flight_log.dart';

class SyncDataService {
  final DatabaseHelper _localDb;
  final AircraftDatabaseHelper _localAircraftDb;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SyncDataService(this._localDb, this._localAircraftDb);

  Future<void> syncAircraftToFirebase() async {
    List<Aircraft> localAircrafts = await _localAircraftDb.getAllAircraft();
    for (var aircraft in localAircrafts) {
      _firestore.collection('aircrafts').doc(aircraft.id.toString()).set(aircraft.toMap());
    }
  }

  Future<void> syncFlightLogsToFirebase() async {
    List<FlightLog> localLogs = await _localDb.getAllFlightLogs();
    for (var log in localLogs) {
      _firestore.collection('flightLogs').doc(log.id.toString()).set(log.toMap());
    }
  }

  Future<void> fetchAircraftFromFirebase() async {
    QuerySnapshot snapshot = await _firestore.collection('aircrafts').get();
    List<Aircraft> aircrafts = snapshot.docs.map((doc) => Aircraft.fromMap(doc.data() as Map<String, dynamic>)).toList();
    
    for (var aircraft in aircrafts) {
      await _localAircraftDb.insertOrUpdateAircraft(aircraft);
    }
  }

  Future<void> fetchFlightLogsFromFirebase() async {
    QuerySnapshot snapshot = await _firestore.collection('flightLogs').get();
    List<FlightLog> flightLogs = snapshot.docs.map((doc) => FlightLog.fromMap(doc.data() as Map<String, dynamic>)).toList();

    for (var log in flightLogs) {
      await _localDb.insertOrUpdateFlightLog(log);
    }
  }
}
