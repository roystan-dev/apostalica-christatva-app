import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import '../widgets/side_drawer_dialog.dart';
import '../widgets/app_header.dart';
import '../utils/topic_functions.dart';
import '../services/article_services.dart';
import '../services/menu_services.dart';

class DynamicPage extends StatefulWidget {
  final String slug;
  final String title;

  const DynamicPage({
    required this.slug,
    required this.title,
    super.key,
  });

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  late Future<List<dynamic>> topics;
  late Future<List<dynamic>> menuFuture;
  bool isDrawerOpen = false;
  bool loading = true;
  String? content;

  @override
  void initState() {
    super.initState();
    fetchPage();
    topics = ArticleServices.fetchTopics();
    menuFuture = MenuServices.fetchMenuItems();
  }

  Future<void> fetchPage() async {
    try {
      final data = await ArticleServices.fetchPageContent(widget.slug);

      setState(() {
        content = data["content"] ?? "<p>No content</p>";
        loading = false;
      });
    } catch (e) {
      setState(() {
        content = "<p>Error loading content</p>";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.grey.shade200,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _CustomHeaderDelegate(
              statusBarHeight: statusBarHeight,
              child: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'BalooTamma2Bold',
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: loading
                ? const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Html(
                      data: content,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10),
        child: AppHeader(
          isDrawerOpen: isDrawerOpen,
          onToggleDrawer: _toggleDrawer,
          onOpenSideDrawer: _openSideDrawer,
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

class _CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;
  final Widget child;

  _CustomHeaderDelegate({
    required this.statusBarHeight,
    required this.child,
  });

  @override
  double get minExtent => statusBarHeight + 70;
  @override
  double get maxExtent => statusBarHeight + 70;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Column(
      children: [
        Container(height: statusBarHeight, color: Colors.grey.shade300),
        child,
      ],
    );
  }

  @override
  bool shouldRebuild(_CustomHeaderDelegate oldDelegate) =>
      oldDelegate.statusBarHeight != statusBarHeight ||
      oldDelegate.child != child;
}
