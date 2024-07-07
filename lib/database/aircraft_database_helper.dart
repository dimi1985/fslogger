import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/aircraft.dart';

class AircraftDatabaseHelper {
  static final AircraftDatabaseHelper _instance = AircraftDatabaseHelper._internal();
  factory AircraftDatabaseHelper() => _instance;
  AircraftDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'aircraft_database.db');

    return await openDatabase(
      databasePath,
      version: 4,  // Updated version
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
            maxWindGusts REAL NOT NULL,
            isMilitary INTEGER NOT NULL DEFAULT 0,
            parkingAirport TEXT NOT NULL,
            hoursFlown REAL NOT NULL DEFAULT 0.0
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Execute additional SQL scripts when upgrading from version 2 to version 3
          await db.execute('ALTER TABLE aircraft ADD COLUMN isMilitary INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE aircraft ADD COLUMN parkingAirport TEXT NOT NULL');
          await db.execute('ALTER TABLE aircraft ADD COLUMN hoursFlown REAL NOT NULL DEFAULT 0.0');
        }
      },
    );
  }

  Future<int> insertAircraft(Aircraft aircraft) async {
    final db = await database;
    return await db.insert('aircraft', aircraft.toMap());
  }

  Future<List<Aircraft>> getAllAircraft() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('aircraft');

    return List.generate(maps.length, (i) {
      return Aircraft.fromMap(maps[i]);
    });
  }

  Future<int> updateAircraft(Aircraft aircraft) async {
    final db = await database;
    return await db.update(
      'aircraft',
      aircraft.toMap(),
      where: 'id = ?',
      whereArgs: [aircraft.id],
    );
  }

  Future<int> deleteAircraft(int id) async {
    final db = await database;
    return await db.delete(
      'aircraft',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  

  Future<void> insertOrUpdateAircraft(Aircraft aircraft) async {
  var existingAircraft = await getAircraftById(aircraft.id ?? 0);
  if (existingAircraft == null) {
    await insertAircraft(aircraft);
  } else {
    await updateAircraft(aircraft);
  }
}

 Future<Aircraft?> getAircraftById(int id) async {
    final db = await database;
    var res = await db.query("aircraft", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Aircraft.fromMap(res.first) : null;
  }

}
