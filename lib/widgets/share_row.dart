import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/article.dart';

class ShareRow extends StatelessWidget {
  final Article article;

  const ShareRow({super.key, required this.article});

  void _shareToWhatsApp(String message) async {
    final whatsappUrl = "whatsapp://send?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      Share.share(message);
    }
  }

  void _shareToMessenger(String message) async {
    final url = Uri.encodeComponent(message);
    final messengerUrl = "fb-messenger://share?link=$url";

    if (await canLaunchUrl(Uri.parse(messengerUrl))) {
      await launchUrl(Uri.parse(messengerUrl),
          mode: LaunchMode.externalApplication);
    } else {
      Share.share(message);
    }
  }

  void _shareToFacebook(String slug) async {
    final articleUrl = "https://apostalicachristatva.in/$slug";
    final fbUrl =
        "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(articleUrl)}";

    if (await canLaunchUrl(Uri.parse(fbUrl))) {
      await launchUrl(Uri.parse(fbUrl), mode: LaunchMode.externalApplication);
    }
  }

  String get _articleMessage {
    return '''
*${article.title}*

${article.description}

Website link:
https://apostalicachristatva.in/${article.slug}
''';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Share.share(_articleMessage),
          child: const Icon(
            Icons.share,
            size: 27,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () => _shareToWhatsApp(_articleMessage),
          child: const Icon(
            FontAwesomeIcons.whatsapp,
            color: Color.fromRGBO(76, 175, 80, 1),
            size: 27,
          ),
        ),
        const SizedBox(width: 4.5),
        GestureDetector(
          onTap: () => _shareToMessenger(_articleMessage),
          child: const Icon(
            FontAwesomeIcons.facebookMessenger,
            size: 27,
            color: Color(0xFF006AFF),
          ),
        ),
        const SizedBox(width: 5.5),
        GestureDetector(
          onTap: () => _shareToFacebook(article.slug),
          child: const Icon(
            FontAwesomeIcons.facebook,
            size: 27,
            color: Color(0xFF1877F2),
          ),
        ),
      ],
    );
  }
}
