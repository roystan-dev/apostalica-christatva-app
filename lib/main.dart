import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/flash_screen.dart';
import 'screens/home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[Background] Message ID: ${message.messageId}');
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _navigatorKey,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const FlashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _messaging;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[Permission] ${settings.authorizationStatus}');

    String? token = await _messaging.getToken();
    setState(() => _fcmToken = token);
    debugPrint('FCM Token: $_fcmToken');

    await _messaging.subscribeToTopic('manual_notifications');

    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  void _onMessageHandler(RemoteMessage message) {
    debugPrint(
      '[Foreground] ${message.notification?.title} | data=${message.data}',
    );

    final notification = message.notification;
    if (notification != null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF148EB7),
          content: Text(
            '${notification.title}\n${notification.body}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'BalooTamma2Medium',
              color: Colors.white,
            ),
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'ಓದಿ',
            onPressed: () => _handleDeepLink(message.data),
            textColor: const Color(0xFFFFF176),
          ),
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint(
      '[Notification Tap] ${message.notification?.title} | data=${message.data}',
    );
    _handleDeepLink(message.data);
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    if (data.containsKey('deep_link')) {
      final url = data['deep_link'] as String;
      launchUrl(Uri.parse(url));
      return;
    }

    if (data.containsKey('article_id')) {
      final articleId = data['article_id'] as String;
      final ctx = _navigatorKey.currentContext;
      if (ctx != null) {
        GoRouter.of(ctx).go('/home?articleId=$articleId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ಅಪೊಸ್ತಲಿಕ ಕ್ರೈಸ್ತತ್ವ',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
