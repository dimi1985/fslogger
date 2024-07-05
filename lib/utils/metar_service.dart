import 'dart:convert';
import 'package:http/http.dart' as http;

class MetarService {
  static const String _apiKey = 'qXAk3-vIC5MxoVwZg3bXi5wD427t6mDd33wrXdz1cGM';

  Future<Map<String, dynamic>?> fetchWeather(String airportCode) async {
    try {
      final metarResponse = await http.get(
        Uri.parse('https://avwx.rest/api/metar/$airportCode'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      final stationResponse = await http.get(
        Uri.parse('https://avwx.rest/api/station/$airportCode'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (metarResponse.statusCode == 200 && stationResponse.statusCode == 200) {
        final metarData = jsonDecode(metarResponse.body);
        final stationData = jsonDecode(stationResponse.body);
        metarData['station_name'] = stationData['name']; // Add the station name to the METAR data
        return metarData;
      } else {
        print('Failed to fetch data. Status code: ${metarResponse.statusCode} / ${stationResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
