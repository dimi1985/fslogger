import 'package:flutter/material.dart';
import 'package:fslogger/utils/applocalizations.dart'; // Import your localization utility

class DetailedMetarPage extends StatelessWidget {
  final String airportCode;
  final Map<String, dynamic>? metarData; // Make nullable to handle potential nulls safely

  const DetailedMetarPage({super.key, required this.airportCode, this.metarData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.translate('metar_report_for') ?? 'METAR Report for $airportCode'),
      ),
      body: metarData == null ? 
        Center(child: CircularProgressIndicator()) : // Show loading spinner if metarData is null
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${localizations?.translate('temperature') ?? "Temperature"}: ${metarData?['temperature']?['value'] ?? "N/A"}°C'),
              Text('${localizations?.translate('wind_speed') ?? "Wind Speed"}: ${metarData?['wind_speed']?['value'] ?? "N/A"} knots'),
              Text('${localizations?.translate('visibility') ?? "Visibility"}: ${metarData?['visibility']?['value'] ?? "N/A"} meters'),
              // Add more details as necessary
            ],
          ),
        ),
    );
  }
}
