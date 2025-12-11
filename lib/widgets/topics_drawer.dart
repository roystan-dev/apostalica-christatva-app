import 'package:flutter/material.dart';
import '../screens/topic_article.dart';

class TopicsDrawer extends StatelessWidget {
  final Future<List<dynamic>> topics;

  const TopicsDrawer({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ವಿಷಯಗಳು',
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
            const Divider(),
            FutureBuilder<List<dynamic>>(
              future: topics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Error loading topics");
                }

                final data = snapshot.data ?? [];

                List<List<String>> rows = [];
                for (var i = 0; i < data.length; i += 2) {
                  String t1 = data[i]['topic_name'];
                  String t2 =
                      (i + 1 < data.length) ? data[i + 1]['topic_name'] : "";
                  rows.add([t1, t2]);
                }

                return GridView.count(
                  crossAxisCount: 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 7,
                  children: rows.map((pair) {
                    return _buildGridRow(context, pair[0], pair[1]);
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(BuildContext context, String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildClickableText(context, text1),
        const SizedBox(width: 16),
        _buildClickableText(context, text2),
      ],
    );
  }

  Widget _buildClickableText(BuildContext context, String text) {
    if (text.isEmpty) return const SizedBox();

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ArticlesByTopicScreen(topicName: text)),
            );
          },
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'BalooTamma2Medium',
              fontSize: 16,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
