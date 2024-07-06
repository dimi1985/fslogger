import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fslogger/main.dart';
import 'package:fslogger/utils/applocalizations.dart';
import 'package:fslogger/utils/language_model.dart';
import 'package:fslogger/utils/settings_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageModel = Provider.of<LanguageModel>(context);
    final localizations = AppLocalizations.of(context);
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations?.translate('settings') ?? 'Settings'), // Localized
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return ListView(
            children: <Widget>[
              SwitchListTile(
                title: Text(localizations?.translate('dark_theme') ??
                    'Dark Theme'), // Localized
                value: settings.darkTheme,
                onChanged: settings.toggleTheme,
              ),
              ListTile(
                title: Text(localizations?.translate('language') ??
                    'Language'), // Localized
                trailing: DropdownButton<Locale>(
                  value: languageModel.locale,
                  icon: const Icon(Icons.arrow_downward),
                  onChanged: (Locale? newValue) {
                    if (newValue != null) {
                      languageModel.setLocale(newValue);
                    }
                  },
                  items:
                      L10n.all.map<DropdownMenuItem<Locale>>((Locale locale) {
                    return DropdownMenuItem<Locale>(
                        value: locale,
                        child: Text(locale.languageCode == 'en'
                            ? localizations?.translate('english') ?? 'English'
                            : localizations?.translate('greek') ?? 'Greek'));
                  }).toList(),
                ),
              ),
              SwitchListTile(
                title: Text(localizations?.translate('default_dynamic_mode') ??
                    'Default to Dynamic Flight Log'), // Localized
                value: settings.defaultDynamicMode,
                onChanged: settings.toggleFlightMode,
              ),
              ListTile(
                title: user != null
                    ? Text('Signed in as ${user.email ?? user.displayName}')
                    : Text(localizations?.translate('sign_in_google') ??
                        'Sign in with Google'),
                onTap: user == null ? signInWithGoogle : null,
              ),
              ListTile(
                title: Text(
                    localizations?.translate('sync_option') ?? 'Sync Option'),
                subtitle: DropdownButton<int>(
                  isExpanded: true,
                  value: settings.syncPreference,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      settings.saveSyncPreference(newValue);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                        value: 0,
                        child: Text(
                            localizations?.translate('sync_automatically') ??
                                'Automatically on App Start')),
                    DropdownMenuItem(
                        value: 1,
                        child: Text(
                            localizations?.translate('manual_trigger') ??
                                'Manual Trigger in Settings')),
                    DropdownMenuItem(
                        value: 2,
                        child: Text(
                            localizations?.translate('periodically_changes') ??
                                'Periodically or On Changes')),
                  ],
                ),
              ),
              if (settings.syncPreference == 1)  // Conditionally display the sync button
                ListTile(
                  title: Text(localizations?.translate('sync_now') ?? 'Sync Now'),
                  trailing: IconButton(
                    icon: Icon(Icons.sync),
                    onPressed: () async {
                      // Assuming syncData is your synchronization function
                      await syncData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data synchronization complete'))
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        assert(!user!.isAnonymous);
        assert(await user!.getIdToken() != null);

        final User? currentUser = _auth.currentUser;
        assert(user!.uid == currentUser!.uid);

        print('signInWithGoogle succeeded: $user');

        return user;
      }
    } catch (error) {
      print('Google sign-in failed: $error');
    }
    return null;
  }
}
