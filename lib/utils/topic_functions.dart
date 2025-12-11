import 'package:flutter/material.dart';
import '../widgets/topics_drawer.dart';

Future<void> showTopicsDrawer(
    BuildContext context, Future<List<dynamic>> topics) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => TopicsDrawer(topics: topics),
  );
}
