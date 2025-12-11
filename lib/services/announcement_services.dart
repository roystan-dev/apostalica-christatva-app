import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/announcement.dart';

class AnnouncementServices {
  static Future<Announcement?> fetchAnnouncement() async {
    final url = Uri.parse(
        "https://apostalicachristatva.in/announcements/get-announcement.php");

    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final data = json.decode(res.body);

    if (data["active"] == false) return null;

    return Announcement.fromJson(data);
  }
}
