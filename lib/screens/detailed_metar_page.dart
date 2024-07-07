import 'package:flutter/material.dart';
import 'package:fslogger/utils/applocalizations.dart'; // Import your localization utility

class DetailedMetarPage extends StatelessWidget {
  final String airportCode;
  final Map<String, dynamic>? metarData;

  const DetailedMetarPage(
      {super.key, required this.airportCode, this.metarData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('metar_report_for') ??
            'METAR Report for $airportCode'),
        backgroundColor: Colors.deepPurple[400],
        elevation: 0,
      ),
      body: metarData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.deepPurple[50],
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.thermostat_outlined,
                          color: Colors.deepPurple),
                      title: Text(localizations?.translate('temperature') ??
                          "Temperature"),
                      subtitle: Text(
                          '${metarData?['temperature']?['value'] ?? "N/A"}°C'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.blue[50],
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.air, color: Colors.blue),
                      title: Text(localizations?.translate('wind_speed') ??
                          "Wind Speed"),
                      subtitle: Text(
                          '${metarData?['wind_speed']?['value'] ?? "N/A"} knots'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.green[50],
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.visibility, color: Colors.green[700]),
                      title: Text(localizations?.translate('visibility') ??
                          "Visibility"),
                      subtitle: Text(
                          '${metarData?['visibility']?['value'] ?? "N/A"} meters'),
                    ),
                  ),
                  // Add more details as necessary, using similar card layouts for consistency
                ],
              ),
            ),
    );
  }
}
