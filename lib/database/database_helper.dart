import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flight_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'flight_log_database.db');

    return await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE aircraft (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            rateOfClimb REAL NOT NULL,
            maxSpeed REAL NOT NULL,
            normalCruiseSpeed REAL NOT NULL,
            maxTakeoffWeight REAL NOT NULL,
            operatingWeight REAL NOT NULL,
            emptyWeight REAL NOT NULL,
            fuelCapacity REAL NOT NULL,
            payloadUseful REAL NOT NULL,
            payloadWithFullFuel REAL NOT NULL,
            maxPayload REAL NOT NULL,
            serviceCeiling REAL NOT NULL,
            takeoffDistance REAL NOT NULL,
            balancedFieldLength REAL NOT NULL,
            landingDistance REAL NOT NULL,
            range REAL NOT NULL,
            maxCrosswindComponent REAL NOT NULL,
            maxTailwindComponent REAL NOT NULL,
            maxWindGusts REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE flightLogs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            duration INTEGER NOT NULL,
            aircraftId INTEGER NOT NULL,
            departureAirport TEXT NOT NULL,
            arrivalAirport TEXT NOT NULL,
            remarks TEXT,
            route TEXT,
            routeDistance REAL,
            FOREIGN KEY (aircraftId) REFERENCES aircraft(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE flightLogs ADD COLUMN route TEXT;
          ''');
          await db.execute('''
            ALTER TABLE flightLogs ADD COLUMN routeDistance REAL;
          ''');
        }
      },
    );
  }

  Future<int> insertFlightLog(FlightLog flightLog) async {
    final db = await database;
    return await db.insert('flightLogs', flightLog.toMap());
  }

  Future<List<FlightLog>> getAllFlightLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flightLogs');

    return List.generate(maps.length, (i) {
      return FlightLog.fromMap(maps[i]);
    });
  }

  Future<int> updateFlightLog(FlightLog flightLog) async {
    final db = await database;
    return await db.update(
      'flightLogs',
      flightLog.toMap(),
      where: 'id = ?',
      whereArgs: [flightLog.id],
    );
  }

  Future<int> deleteFlightLog(int id) async {
    final db = await database;
    return await db.delete(
      'flightLogs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> insertOrUpdateFlightLog(FlightLog log) async {
  var existingLog = await getFlightLogById(log.id ?? 0);
  if (existingLog == null) {
    await insertFlightLog(log);
  } else {
    await updateFlightLog(log);
  }
}

  Future<FlightLog?> getFlightLogById(int id) async {
    final db = await database;
    var res = await db.query("flightLogs", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? FlightLog.fromMap(res.first) : null;
  }
}
