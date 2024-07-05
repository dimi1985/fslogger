import 'dart:convert';
import 'package:http/http.dart' as http;

class FlightPlanService {
  final String apiKey = 'By0PyLeFv0ZuOEvtpfdBLdull4T29z1tUUbndyKF';
  final String baseUrl = 'https://api.flightplandatabase.com';

  String _encodeBasicAuth() {
    // Encode API key as Basic Auth username with a blank password
    String credentials = '$apiKey:';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(credentials);
  }

  Future<Map<String, dynamic>?> fetchFlightPlan(
      String departureICAO, String arrivalICAO) async {
    final url = Uri.parse('$baseUrl/plan/$departureICAO/$arrivalICAO');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Basic ${_encodeBasicAuth()}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch flight plan. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createFlightPlan(
      String departureICAO, String arrivalICAO, String departureName, String arrivalName) async {
    final planData = {
      'fromICAO': departureICAO,
      'toICAO': arrivalICAO,
      'fromName': departureName,  // Adding required fields based on API response
      'toName': arrivalName,      // Adding required fields based on API response
      'route': {
        'nodes': [
          {'ident': departureICAO, 'type': 'APT', 'name': departureName},
          {'ident': arrivalICAO, 'type': 'APT', 'name': arrivalName}
        ]
      },
    };

    final response = await http.post(
      Uri.parse('$baseUrl/plan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${_encodeBasicAuth()}'
      },
      body: jsonEncode(planData),
    );

    print('Request Body: ${jsonEncode(planData)}');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Failed to create flight plan. Status code: ${response.statusCode}');
      print('Error: ${response.body}');
      return null;
    }
  }
}
