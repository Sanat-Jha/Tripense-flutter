import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // For making HTTP requests

/// Universal function to fetch data from an API.
/// [url] is the endpoint where the request is sent.
/// [data] is a map containing the data to be sent in the request body.
/// Returns a JSON response if successful, or prints an error if not.
Future<dynamic> fetchData(String url, Map<String, dynamic> data) async {
  try {
    // Make the POST request
    final response = await http.post(
      Uri.parse("https://127.0.0.1:8000/api/" + url),
      headers: {
        'Content-Type': 'application/json',
        'X-Api-Key': 'qwertyuioplkjhgfdsazxcvbnm', // Optional: Add your API key if needed
      },
      body: jsonEncode(data), // Encode the map as JSON
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Return the decoded JSON response
      return jsonDecode(response.body);
    } else {
      // Handle non-successful response
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    // Handle exceptions such as network errors
    print('Exception: $e');
  }

  // Return null in case of error
  return null;
}



Future<void> saveTripIdList(List<int> intList) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert List<int> to List<String> because SharedPreferences does not support List<int> directly
  List<String> stringList = intList.map((e) => e.toString()).toList();

  await prefs.setStringList('integerListKey', stringList);
}


Future<List<int>> getTripIdList() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String>? stringList = prefs.getStringList('integerListKey');

  if (stringList != null) {
    return stringList.map((e) => int.parse(e)).toList();
  } else {
    saveTripIdList([]);
    return []; // Return an empty list if no data is found
  }
}
