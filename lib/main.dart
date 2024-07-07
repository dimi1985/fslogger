import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fslogger/database/aircraft_database_helper.dart';
import 'package:fslogger/database/database_helper.dart';
import 'package:fslogger/screens/home_page.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:fslogger/utils/language_model.dart';
import 'package:fslogger/utils/settings_model.dart';
import 'package:fslogger/utils/sync_data_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure plugin services are initialized.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language_code') ?? 'en';

// Manually specified Firebase options
  const firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyCPHvMrZLiMOyvjzX5Nu07Ef84GTdlhy8s", // API key from your JSON
    appId:
        "1:607305081799:android:126e747b55c26cb8fdefe2", // App ID from your JSON
    projectId: "pilotvision-aa506", // Project ID from your JSON
    messagingSenderId:
        "607305081799", // Use the project number as messagingSenderId
    storageBucket:
        "pilotvision-aa506.appspot.com", // Storage bucket from your JSON
  );

 // Initialize Firebase
  await Firebase.initializeApp(
    options: firebaseOptions,
  );


  var settingsModel = SettingsModel();
  await settingsModel.loadPreferences();

  if (settingsModel.syncPreference == 0) {
    // Trigger sync automatically
    await syncData(); // Your function to sync data
  }

  

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsModel()),
        ChangeNotifierProvider(
          create: (context) =>
              LanguageModel(initialLocale: Locale(languageCode)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> syncData() async {
  // Assume _localDb and _localAircraftDb are initialized somewhere in your application
  DatabaseHelper localDb = DatabaseHelper();
  AircraftDatabaseHelper localAircraftDb = AircraftDatabaseHelper();
  SyncDataService syncService = SyncDataService(localDb, localAircraftDb);

  // Sync local data to Firestore
  await syncService.syncAircraftToFirebase();
  await syncService.syncFlightLogsToFirebase();

  // Fetch data from Firestore and update local database
  await syncService.fetchAircraftFromFirebase();
  await syncService.fetchFlightLogsFromFirebase();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsModel, LanguageModel>(
      builder: (context, settings, language, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FS Logger',
          locale: language.locale,
          theme: ThemeData(
            brightness: settings.darkTheme ? Brightness.dark : Brightness.light,
          ),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          home: const HomePage(),
        );
      },
    );
  }
}
