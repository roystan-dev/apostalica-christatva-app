import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ArticleServices {
  static Future<List<dynamic>> fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse('https://apostalicachristatva.in/api/articles.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List<dynamic>) {
          if (data.length > 5) {
            return data.sublist(0, 5);
          } else {
            return data;
          }
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception(
            'Failed to load articles (status ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection. Turn on the internet.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<dynamic>> fetchTopics() async {
    try {
      final response = await http.get(
        Uri.parse('https://apostalicachristatva.in/api/topics.php'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<dynamic> fetchArticleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://apostalicachristatva.in/api/article.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          throw Exception(data['error']);
        }
        return data;
      } else {
        throw Exception('Failed to load article');
      }
    } on SocketException {
      throw Exception('No internet connection. Turn on the internet.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<dynamic>> fetchLatestArticles(int articleId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://apostalicachristatva.in/api/article1.php?id=$articleId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List<dynamic>) {
          return data;
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to load latest articles');
      }
    } on SocketException {
      throw Exception('No internet connection. Turn on the internet.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchPageContent(String slug) async {
    final response = await http.get(
      Uri.parse("https://apostalicachristatva.in/api/page.php?slug=$slug"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load page");
    }
  }
}
