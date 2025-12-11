import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuServices {
  static Future<List<dynamic>> fetchMenuItems() async {
    final response = await http.get(
      Uri.parse("https://apostalicachristatva.in/api/pages.php"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }
}
