import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../widgets/article_states.dart';
import '../widgets/side_drawer_dialog.dart';
import '../widgets/reusable_sliver_header.dart';
import '../utils/topic_functions.dart';
import '../services/article_services.dart';
import '../services/menu_services.dart';

class ArticleScreen extends StatefulWidget {
  final int articleId;

  const ArticleScreen({super.key, required this.articleId});

  @override
  ArticleScreenState createState() => ArticleScreenState();
}

class ArticleScreenState extends State<ArticleScreen> {
  late Future<dynamic> article;
  late Future<List<dynamic>> latestArticles;
  late Future<List<dynamic>> topics;
  late Future<List<dynamic>> menuFuture;
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

    article = ArticleServices.fetchArticleById(widget.articleId);
    latestArticles = ArticleServices.fetchLatestArticles(widget.articleId);
    topics = ArticleServices.fetchTopics();
    menuFuture = MenuServices.fetchMenuItems();
  }

  Future<List<dynamic>> fetchTopics() async {
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade300,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<dynamic>(
        future: article,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingStateWidget(
              screenWidth: screenWidth,
              progress: _progress,
            );
          } else if (snapshot.hasError) {
            final errorMsg = snapshot.error.toString();

            if (errorMsg.contains('No internet connection')) {
              return NoInternetWidget(
                onRetry: () {
                  setState(() {
                    article = ArticleServices.fetchArticles();
                  });
                },
              );
            }

            return ErrorStateWidget(errorMsg: errorMsg);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles available'));
          }

          final articleData = snapshot.data;
          final htmlContent = articleData['content'] ?? 'No content available';

          return CustomScrollView(
            slivers: [
              ReusableSliverHeader(
                isDrawerOpen: isDrawerOpen,
                onToggleDrawer: _toggleDrawer,
                onOpenSideDrawer: _openSideDrawer,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: Image.network(
                          articleData['image'] ?? '',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            articleData['topic'] ?? 'Unknown',
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
                            articleData['date'] ?? 'Unknown Date',
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
                        articleData['title'] ?? 'Untitled',
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
                          articleData['description'] ?? '',
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
                        articleData['author'] ?? 'Unknown Author',
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
                      SizedBox(height: 4),
                      Html(
                        data: htmlContent,
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
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              final title = articleData['title'] ?? '';
                              final description =
                                  articleData['description'] ?? '';
                              final slug = articleData['slug'] ?? '';

                              final message = '''
*$title*

$description

Website link:
https://apostalicachristatva.in/$slug
''';

                              Share.share(message); // share_plus
                            },
                            child: const Icon(
                              Icons.share,
                              size: 27,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              final title = articleData['title'] ?? '';
                              final description =
                                  articleData['description'] ?? '';
                              final slug = articleData['slug'] ?? '';

                              final message = '''
*$title*

$description

Website link:
https://apostalicachristatva.in/$slug


''';

                              shareToWhatsApp(message);
                            },
                            child: const Icon(
                              FontAwesomeIcons.whatsapp,
                              color: Color.fromRGBO(76, 175, 80, 1),
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 4.5),
                          GestureDetector(
                            onTap: () async {
                              final title = articleData['title'] ?? '';
                              final description =
                                  articleData['description'] ?? '';
                              final slug = articleData['slug'] ?? '';

                              final message = '''
*$title*

$description

Website link:
https://apostalicachristatva.in/$slug
''';

                              final url = Uri.encodeComponent(message);
                              final messengerUrl =
                                  "fb-messenger://share?link=$url";

                              if (await canLaunchUrl(Uri.parse(messengerUrl))) {
                                await launchUrl(Uri.parse(messengerUrl),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                Share.share(message);
                              }
                            },
                            child: const Icon(
                              FontAwesomeIcons.facebookMessenger,
                              size: 27,
                              color: Color(0xFF006AFF),
                            ),
                          ),
                          const SizedBox(width: 5.5),
                          GestureDetector(
                            onTap: () async {
                              final slug = articleData['slug'] ?? '';
                              final articleUrl =
                                  "https://apostalicachristatva.in/$slug";

                              final fbUrl =
                                  "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(articleUrl)}";

                              if (await canLaunchUrl(Uri.parse(fbUrl))) {
                                await launchUrl(Uri.parse(fbUrl),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: const Icon(
                              FontAwesomeIcons.facebook,
                              size: 27,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      const Text(
                        'ಇನ್ನಷ್ಟು ಓದಿ:',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'BalooTamma2Bold',
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<dynamic>>(
                        future: latestArticles,
                        builder: (context, latestSnapshot) {
                          if (latestSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (latestSnapshot.hasError) {
                            return Center(
                                child: Text('Error: \${latestSnapshot.error}'));
                          }

                          if (!latestSnapshot.hasData ||
                              latestSnapshot.data!.isEmpty) {
                            return const Text('No latest articles available');
                          }

                          final latestArticlesData = latestSnapshot.data!;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final article = latestArticlesData[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleScreen(
                                        articleId:
                                            int.parse(article['id'].toString()),
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final totalWidth = constraints.maxWidth;

                                        const double dashWidth = 1.5;
                                        const double dashMargin = 1.4;
                                        final dashTotal =
                                            dashWidth + dashMargin;

                                        final dashCount =
                                            (totalWidth / dashTotal).floor();
                                        return Row(
                                          children:
                                              List.generate(dashCount, (index) {
                                            return Container(
                                              width: dashWidth,
                                              height: 1,
                                              color: Colors.black,
                                              margin: EdgeInsets.only(
                                                  right: index == dashCount - 1
                                                      ? 0
                                                      : dashMargin),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article['title'] ??
                                                      'Untitled',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'BalooTamma2Bold',
                                                    fontSize: 17,
                                                    color: Colors.black,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 5.0),
                                                Text(
                                                  article['author'] ??
                                                      'Unknown Author',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'BalooTamma2Bold',
                                                    fontSize: 14,
                                                    color: Color(0xFF7C7474),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (article['image'] != null)
                                            ClipRRect(
                                              child: Image.network(
                                                article['image'],
                                                width: 72,
                                                height: 72,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
