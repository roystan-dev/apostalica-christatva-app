import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'article.dart';
import 'dart:io';
import '../widgets/side_drawer_dialog.dart';
import '../widgets/reusable_sliver_header.dart';
import '../utils/topic_functions.dart';
import '../services/article_services.dart';
import '../services/menu_services.dart';

class AllArticlesScreen extends StatefulWidget {
  const AllArticlesScreen({super.key});

  @override
  State<AllArticlesScreen> createState() => _AllArticlesScreenState();
}

class _AllArticlesScreenState extends State<AllArticlesScreen> {
  List<dynamic> _allArticles = [];
  List<dynamic> _displayedArticles = [];
  late Future<List<dynamic>> topics;
  late Future<List<dynamic>> menuFuture;
  static const int _initialDisplayCount = 10;
  static const int _loadMoreStep = 10;
  int _nextIndex = 0;
  bool _isLoading = true;
  bool _hasMore = false;

  bool isDrawerOpen = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchAllArticles();
    topics = ArticleServices.fetchTopics();
    menuFuture = MenuServices.fetchMenuItems();
  }

  Future<void> _fetchAllArticles() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://apostalicachristatva.in/api/articles.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List<dynamic>) {
          _allArticles = data;
          final initialCount = min(_initialDisplayCount, _allArticles.length);
          _displayedArticles = _allArticles.sublist(0, initialCount);
          _nextIndex = initialCount;
          _hasMore = _nextIndex < _allArticles.length;
        } else {
          _allArticles = [];
          _displayedArticles = [];
          _hasMore = false;
        }
      } else {
        _allArticles = [];
        _displayedArticles = [];
        _hasMore = false;
      }

      setState(() {
        _isLoading = false;
      });
    } on SocketException {
      setState(() {
        _isLoading = false;
        _isOffline = true;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMoreArticles() {
    final remaining = _allArticles.length - _nextIndex;
    if (remaining <= 0) return;

    final countToTake = min(_loadMoreStep, remaining);
    final nextBatch =
        _allArticles.sublist(_nextIndex, _nextIndex + countToTake);

    setState(() {
      _displayedArticles.addAll(nextBatch);
      _nextIndex += nextBatch.length;
      _hasMore = _nextIndex < _allArticles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade300,
      statusBarIconBrightness: Brightness.dark,
    ));

    if (_isOffline) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಲಭ್ಯವಿಲ್ಲ.\n'
                  'ಇಂಟರ್ನೆಟ್ ಆನ್ ಮಾಡಿ ಮತ್ತು ಕೆಳಗಿರುವ ರಿಫ್ರೆಶ್ ಬಟನ್ ಒತ್ತಿ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'BalooTamma2ExtraBold',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _fetchAllArticles();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF148EB7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ರಿಫ್ರೆಶ್',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'BalooTamma2ExtraBold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ReusableSliverHeader(
              isDrawerOpen: isDrawerOpen,
              onToggleDrawer: _toggleDrawer,
              onOpenSideDrawer: _openSideDrawer,
            ),
            if (_isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_displayedArticles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'No articles',
                      style: TextStyle(
                        fontFamily: 'BalooTamma2Regular',
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 6.0,
                  ),
                  child: Center(
                    child: Text(
                      'ಎಲ್ಲಾ ಲೇಖನಗಳು',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'BalooTamma2Bold',
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _displayedArticles.length) {
                    final article = _displayedArticles[index];
                    final title = article['title'] ?? 'ಅಜ್ಞಾತ ಶೀರ್ಷಿಕೆ';
                    final author = article['author'] ?? 'Unknown Author';
                    final date = article['date'] ?? 'Unknown Date';
                    final imageUrl = article['image'];

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: GestureDetector(
                        onTap: () {
                          final int id = article['id'] is int
                              ? article['id']
                              : int.parse(article['id'].toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleScreen(articleId: id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 1.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index != 0) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(110, (i) {
                                    return const Expanded(
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.black,
                                        size: 2.5,
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontFamily: 'BalooTamma2Bold',
                                            fontSize: 17,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          author,
                                          style: const TextStyle(
                                            fontFamily: 'BalooTamma2Bold',
                                            fontSize: 15,
                                            color: Color(0xFF7C7474),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          date,
                                          style: const TextStyle(
                                            fontFamily: 'BalooTamma2Medium',
                                            fontSize: 14,
                                            color: Color(0xFF7C7474),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (imageUrl != null && imageUrl.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, left: 8.0),
                                      child: ClipRRect(
                                        child: Image.network(
                                          imageUrl,
                                          width: 80,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Icon(
                                        Icons.article,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: _hasMore
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF148EB7),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              onPressed: _loadMoreArticles,
                              child: const Text(
                                'ಇನ್ನಷ್ಟು ಲೇಖನಗಳು',
                                style: TextStyle(
                                  fontFamily: 'BalooTamma2Bold',
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'ಇನ್ನು ಯಾವುದೇ ಲೇಖನಗಳಿಲ್ಲ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'BalooTamma2Regular',
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                  );
                },
                childCount: _displayedArticles.length + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDrawer() async {
    if (!isDrawerOpen) {
      setState(() {
        isDrawerOpen = true;
      });
      await showTopicsDrawer(context, topics);
      setState(() {
        isDrawerOpen = false;
      });
    } else {
      Navigator.pop(context);
      setState(() {
        isDrawerOpen = false;
      });
    }
  }

  void _openSideDrawer() {
    showDialog(
      context: context,
      builder: (context) {
        return SideDrawerDialog(menuFuture: menuFuture);
      },
    );
  }
}
