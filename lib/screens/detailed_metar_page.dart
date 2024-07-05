import 'package:flutter/material.dart';

class DetailedMetarPage extends StatelessWidget {
  final String airportCode;
  final Map<String, dynamic> metarData;

  const DetailedMetarPage({super.key, required this.airportCode, required this.metarData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('METAR Report for $airportCode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperature: ${metarData['temperature']['value']}°C'),
            Text('Wind Speed: ${metarData['wind_speed']['value']} knots'),
            Text('Visibility: ${metarData['visibility']['value']} meters'),
            // Add more details as necessary
          ],
        ),
      ),
    );
  }
}
