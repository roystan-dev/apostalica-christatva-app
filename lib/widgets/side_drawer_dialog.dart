import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/all_articles.dart';
import '../screens/dynamic_page.dart';

class SideDrawerDialog extends StatelessWidget {
  final Future<List<dynamic>> menuFuture;

  const SideDrawerDialog({super.key, required this.menuFuture});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 18.0,
                        top: 10.0,
                        right: 10.0,
                        bottom: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ಮೆನು',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BalooTamma2Bold',
                              color: Color(0xFF148EB7),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text(
                        'ಮುಖಪುಟ',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'BalooTamma2Medium',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                          );
                        });
                      },
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: menuFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        final pages = snapshot.data!;
                        return Column(
                          children: pages.map((page) {
                            return ListTile(
                              title: Text(
                                page['title'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'BalooTamma2Medium',
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DynamicPage(
                                        slug: page['slug'],
                                        title: page['title'],
                                      ),
                                    ),
                                  );
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text(
                        'ಎಲ್ಲಾ ಲೇಖನಗಳು',
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: 'BalooTamma2Medium',
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AllArticlesScreen()),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
