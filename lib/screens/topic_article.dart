import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../widgets/article_states.dart';
import '../widgets/side_drawer_dialog.dart';
import '../widgets/reusable_sliver_header.dart';
import '../widgets/share_row.dart';
import '../utils/topic_functions.dart';
import '../services/article_services.dart';
import '../services/menu_services.dart';
import '../models/article.dart';

class ArticlesByTopicScreen extends StatefulWidget {
  final String topicName;

  const ArticlesByTopicScreen({super.key, required this.topicName});

  @override
  ArticlesByTopicScreenState createState() => ArticlesByTopicScreenState();
}

class ArticlesByTopicScreenState extends State<ArticlesByTopicScreen> {
  late Future<List<Article>> _articles;
  late Future<List<dynamic>> topics;
  late Future<List<dynamic>> menuFuture;
  String? topicDescription;
  String? topicImage;
  bool isDrawerOpen = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _progress = 0.0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.02;
        });
      } else {
        timer.cancel();
      }
    });

    _articles = fetchArticlesByTopic(widget.topicName);
    topics = ArticleServices.fetchTopics();
    menuFuture = MenuServices.fetchMenuItems();
  }

  Future<List<Article>> fetchArticlesByTopic(String topicName) async {
    try {
      final url = Uri.parse(
          'https://apostalicachristatva.in/api/get_articles_by_topic.php?topic_name=$topicName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          if (data[0]['topic_description'] != null) {
            setState(() {
              topicDescription = data[0]['topic_description'];
            });
          }

          if (data[0]['topic_image'] != null) {
            setState(() {
              topicImage = data[0]['topic_image'];
            });
          }
        }

        return data.map((article) => Article.fromJson(article)).toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } on SocketException {
      throw Exception('No internet connection. Turn on the internet.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade300,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Article>>(
          future: _articles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingStateWidget(
                screenWidth: MediaQuery.of(context).size.width,
                progress: _progress,
              );
            } else if (snapshot.hasError) {
              final errorMsg = snapshot.error.toString();

              if (errorMsg.contains('No internet connection')) {
                return NoInternetWidget(
                  onRetry: () {
                    setState(() {
                      _articles = fetchArticlesByTopic(widget.topicName);
                    });
                  },
                );
              }

              return ErrorStateWidget(errorMsg: errorMsg);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'ಈ ವಿಷಯದ ಬಗ್ಗೆ ಪ್ರಸ್ತುತ ಯಾವುದೇ ಲೇಖನಗಳಿಲ್ಲ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontFamily: 'BalooTamma2ExtraBold',
                    ),
                  ),
                ),
              );
            } else {
              final articles = snapshot.data!;

              return Scaffold(
                  backgroundColor: Colors.white,
                  body: Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    child: CustomScrollView(
                      slivers: [
                        ReusableSliverHeader(
                          isDrawerOpen: isDrawerOpen,
                          onToggleDrawer: _toggleDrawer,
                          onOpenSideDrawer: _openSideDrawer,
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 0.0,
                                right: 0.0,
                                bottom: 14.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (topicImage != null)
                                    SizedBox(
                                      width: double.infinity,
                                      height: 180,
                                      child: Image.network(
                                        topicImage!,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      widget.topicName,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontFamily: 'BalooTamma2ExtraBold',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (topicDescription != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 0.0),
                                      child: Text(
                                        topicDescription!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontFamily: 'BalooTamma2Regular',
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final article = articles[index];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 17.0,
                                  right: 17.0,
                                  bottom: 14.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ArticleDetailScreen(
                                                article: article),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(110, (index) {
                                          return Expanded(
                                            child: Icon(
                                              Icons.star,
                                              color: Colors.black,
                                              size: 2.5,
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article.title,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'BalooTamma2Bold',
                                                    fontSize: 17,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  article.author,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'BalooTamma2Bold',
                                                    fontSize: 15,
                                                    color: Color(0xFF7C7474),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  article.date,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'BalooTamma2Medium',
                                                    fontSize: 14,
                                                    color: Color(0xFF7C7474),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (article.image != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Image.network(
                                                article.image!,
                                                width: 80,
                                                height: 72,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            const Padding(
                                              padding: EdgeInsets.all(0.0),
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
                              );
                            },
                            childCount: articles.length,
                          ),
                        )
                      ],
                    ),
                  ));
            }
          },
        ));
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

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  ArticleDetailScreenState createState() => ArticleDetailScreenState();
}

class ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Future<List<Article>> _relatedArticles;
  late Future<List<dynamic>> topics;
  late Future<List<dynamic>> menuFuture;

  @override
  void initState() {
    super.initState();
    _relatedArticles =
        fetchRelatedArticles(widget.article.topicName, widget.article.id);
    topics = ArticleServices.fetchTopics();
    menuFuture = MenuServices.fetchMenuItems();
  }

  Future<List<Article>> fetchRelatedArticles(
      String topicName, int currentArticleId) async {
    try {
      final url = Uri.parse(
          'https://apostalicachristatva.in/api/get_articles_by_topic.php?topic_name=$topicName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final articles =
            data.map((article) => Article.fromJson(article)).toList();

        return articles
            .where((article) => article.id != currentArticleId)
            .take(10)
            .toList();
      } else {
        throw Exception('Failed to load related articles');
      }
    } on SocketException {
      throw Exception('No internet connection. Turn on the internet.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  bool isDrawerOpen = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade300,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          ReusableSliverHeader(
            isDrawerOpen: isDrawerOpen,
            onToggleDrawer: _toggleDrawer,
            onOpenSideDrawer: _openSideDrawer,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.article.image != null)
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        widget.article.image!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        widget.article.topicName,
                        style: TextStyle(
                          fontFamily: 'BalooTamma2Medium',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 8,
                        height: 20,
                        color: Color(0xFF148EB7),
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.article.date,
                        style: TextStyle(
                          fontFamily: 'BalooTamma2Medium',
                          fontSize: 16,
                          color: Color(0xFF7C7474),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.article.title,
                    style: TextStyle(
                      fontFamily: 'BalooTamma2Bold',
                      fontSize: 24,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                    ),
                    child: Text(
                      widget.article.description,
                      style: const TextStyle(
                        fontFamily: 'BalooTamma2Regular',
                        fontSize: 15,
                        height: 1.55,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.article.author,
                    style: TextStyle(
                      fontFamily: 'BalooTamma2Bold',
                      fontSize: 15,
                      color: Color(0xFF7C7474),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 70,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  Html(
                    data: widget.article.content,
                    style: {
                      "body": Style(
                        fontFamily: 'BalooTamma2Regular',
                        fontSize: FontSize(17),
                        lineHeight: LineHeight(1.7),
                        color: Colors.black,
                        padding: HtmlPaddings.zero,
                        margin: Margins.zero,
                      ),
                      "h2": Style(
                        fontSize: FontSize(17),
                        fontFamily: 'BalooTamma2Bold',
                        margin: Margins.only(bottom: 12, top: 22),
                        lineHeight: LineHeight(1.4),
                      ),
                      "p": Style(
                        fontSize: FontSize(15),
                        lineHeight: LineHeight(1.85),
                        margin: Margins.only(bottom: 12),
                      ),
                      "ul": Style(
                        padding: HtmlPaddings.only(left: 14),
                        margin: Margins.only(bottom: 6, top: 6),
                        listStyleType: ListStyleType.disc,
                      ),
                      "li": Style(
                        fontSize: FontSize(15),
                        lineHeight: LineHeight(1.85),
                        margin: Margins.only(bottom: 12),
                      ),
                      "blockquote": Style(
                        fontSize: FontSize(15),
                        margin: Margins.only(top: 16, bottom: 16),
                        padding: HtmlPaddings.only(
                            top: 12, bottom: 12, left: 14, right: 14),
                        backgroundColor: const Color(0xFFF0F0F0),
                        border: Border(
                          left: BorderSide(width: 3, color: Colors.grey),
                        ),
                      ),
                      "i": Style(fontStyle: FontStyle.italic),
                      "em": Style(fontStyle: FontStyle.italic),
                      "strong": Style(fontWeight: FontWeight.w700),
                      "b": Style(fontWeight: FontWeight.w700),
                    },
                  ),
                  SizedBox(height: 14),
                  ShareRow(article: widget.article),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 8.0, 8.0, 10.0),
              child: Text(
                'ಈ ವಿಷಯದ ಮೇಲೆ ಇನ್ನಷ್ಟು ಲೇಖನಗಳು:',
                style: const TextStyle(
                  fontFamily: 'BalooTamma2Bold',
                  fontSize: 16,
                  color: Color(0xFF148EB7),
                ),
              ),
            ),
          ),
          FutureBuilder<List<Article>>(
            future: _relatedArticles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(''),
                  ),
                );
              } else {
                final relatedArticles = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = relatedArticles[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(110, (index) {
                                  return Expanded(
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.black,
                                      size: 2.5,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.title,
                                          style: TextStyle(
                                            fontFamily: 'BalooTamma2Bold',
                                            fontSize: 17,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          article.author,
                                          style: TextStyle(
                                            fontFamily: 'BalooTamma2Bold',
                                            color: Color(0xFF7C7474),
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                  article.image != null
                                      ? Image.network(
                                          article.image!,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.article),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: relatedArticles.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void shareToWhatsApp(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
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
