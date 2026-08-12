import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// void main() {
//   runApp(MyApp());
// } //

// Future main() async {
//   runApp(MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer],
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: MyStyle().fontName,
        scaffoldBackgroundColor: MyStyle().scaffoldBackground,
        primaryColor: MyStyle().mainColor,
        colorScheme: ColorScheme.fromSeed(seedColor: MyStyle().mainColor),
        cardTheme: CardThemeData(
          elevation: 0,
          color: MyStyle().surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MyStyle().radiusM),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: MyStyle().bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: Authen(),
    );
  }
}
