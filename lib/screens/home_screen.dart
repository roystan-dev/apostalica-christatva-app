import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'article.dart';
import 'all_articles.dart';
import '../widgets/article_states.dart';
import '../widgets/side_drawer_dialog.dart';
import '../widgets/reusable_sliver_header.dart';
import '../utils/topic_functions.dart';
import '../services/article_services.dart';
import '../services/menu_services.dart';
import '../services/announcement_services.dart';
import '../models/announcement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> articles;
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
    articles = ArticleServices.fetchArticles();
    topics = ArticleServices.fetchTopics();
    checkAnnouncement();
    menuFuture = MenuServices.fetchMenuItems();
  }

  void checkAnnouncement() async {
    Announcement? ann = await AnnouncementServices.fetchAnnouncement();
    if (ann == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int seenCount = prefs.getInt("ann_${ann.id}_views") ?? 0;

    if (seenCount >= ann.maxViews) return;

    await Future.delayed(Duration(seconds: ann.delaySeconds));

    if (!mounted) return;

    showAnnouncementDialog(context, ann);

    prefs.setInt("ann_${ann.id}_views", seenCount + 1);
  }

  void showAnnouncementDialog(BuildContext context, Announcement ann) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            width: 350,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    if (ann.imageUrl != null)
                      Image.network(
                        ann.imageUrl!,
                        width: 350,
                        fit: BoxFit.cover,
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ann.buttonColor != null
                            ? Color(ann.buttonColor!)
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        final url = Uri.parse(ann.linkUrl!);
                        launchUrl(url);
                      },
                      child: Text(
                        ann.buttonText ?? "Open",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'BalooTamma2Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade200,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<dynamic>>(
        future: articles,
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
                    articles = ArticleServices.fetchArticles();
                  });
                },
              );
            }

            return ErrorStateWidget(errorMsg: errorMsg);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles available'));
          }
          final articlesData = snapshot.data!;
          return CustomScrollView(
            slivers: [
              ReusableSliverHeader(
                isDrawerOpen: isDrawerOpen,
                onToggleDrawer: _toggleDrawer,
                onOpenSideDrawer: _openSideDrawer,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    buildArticleCard(context, articlesData[0]),
                    ...articlesData
                        .skip(1)
                        .map((article) => buildArticleTile(context, article)),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 10.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF148EB7),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AllArticlesScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'ಎಲ್ಲಾ ಲೇಖನಗಳನ್ನು ಓದಿ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'BalooTamma2Bold',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildArticleCard(BuildContext context, dynamic article) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Image.network(
              article['image']?.toString() ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                article['topic']?.toString() ?? 'Unknown',
                style: TextStyle(
                  fontFamily: 'BalooTamma2Medium',
                  fontSize: isDesktop ? 19 : 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              Container(width: 8, height: 20, color: Colors.blue),
              const SizedBox(width: 5),
              Text(
                article['date']?.toString() ?? 'Unknown Date',
                style: TextStyle(
                  fontFamily: 'BalooTamma2Medium',
                  fontSize: isDesktop ? 19 : 16,
                  color: const Color(0xFF7C7474),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              final articleId =
                  int.tryParse(article['id']?.toString() ?? '0') ?? 0;
              if (articleId > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleScreen(articleId: articleId),
                  ),
                );
              }
            },
            child: Text(
              article['title']?.toString() ?? 'Untitled',
              style: TextStyle(
                fontFamily: 'BalooTamma2Bold',
                fontSize: 21,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article['description']?.toString() ?? 'No description',
            style: TextStyle(
              fontFamily: 'BalooTamma2Regular',
              fontSize: 15,
              color: Colors.black,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article['author']?.toString() ?? 'Unknown Author',
            style: TextStyle(
              fontFamily: 'BalooTamma2Bold',
              fontSize: 15,
              color: const Color(0xFF7C7474),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget buildArticleTile(BuildContext context, dynamic article) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    return GestureDetector(
      onTap: () {
        final articleId = int.tryParse(article['id']?.toString() ?? '0') ?? 0;
        if (articleId > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleScreen(articleId: articleId),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: 18, right: 18, top: 10.0, bottom: 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isDesktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const double dashWidth = 1.5;
                  const double dashMargin = 1.4;
                  final dashTotal = dashWidth + dashMargin;
                  final dashCount = (totalWidth / dashTotal).floor();
                  return Row(
                    children: List.generate(dashCount, (index) {
                      return Container(
                        width: dashWidth,
                        height: 1,
                        color: Colors.black,
                        margin: EdgeInsets.only(
                            right: index == dashCount - 1 ? 0 : dashMargin),
                      );
                    }),
                  );
                },
              ),
            SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: isDesktop ? Offset(0, 0) : const Offset(0, 0),
                  child: SizedBox(
                    width: 80,
                    height: 59,
                    child: Image.network(
                      article['image']?.toString() ??
                          'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey[300]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            article['topic']?.toString() ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: 'BalooTamma2Medium',
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(width: 6, height: 16, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text(
                            article['date']?.toString() ?? 'Unknown Date',
                            style: TextStyle(
                              fontFamily: 'BalooTamma2Medium',
                              fontSize: 13,
                              color: const Color(0xFF7C7474),
                            ),
                          ),
                        ],
                      ),
                      if (isDesktop) const SizedBox(height: 5),
                      Text(
                        article['title']?.toString() ?? 'Untitled',
                        style: TextStyle(
                          fontFamily: 'BalooTamma2Bold',
                          fontSize: isDesktop ? 22 : 17,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isDesktop) const SizedBox(height: 5),
                      Text(
                        article['author']?.toString() ?? 'Unknown Author',
                        style: TextStyle(
                          fontFamily: 'BalooTamma2Bold',
                          fontSize: isDesktop ? 16 : 13,
                          color: const Color(0xFF7C7474),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
