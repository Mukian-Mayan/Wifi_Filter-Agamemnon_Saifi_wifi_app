import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'components/app_state.dart';
import 'components/storage.dart';
import 'components/theme.dart';

import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/network_detail_page.dart';
import 'pages/speed_test_page.dart';
import 'pages/security_page.dart';
import 'pages/analytics_page.dart';
import 'pages/saved_page.dart';
import 'pages/filter_page.dart';
import 'pages/radar_page.dart';
import 'pages/settings_page.dart';
import 'pages/tips_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const SaifiApp());
}

class SaifiApp extends StatelessWidget {
  const SaifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (_, state, __) {
          return MaterialApp(
            title: 'Saifi',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: state.themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashPage(),
              '/onboarding': (_) => const OnboardingPage(),
              '/home': (_) => const HomePage(),
              '/scan': (_) => const ScanPage(),
              '/detail': (_) => const NetworkDetailPage(),
              '/speed': (_) => const SpeedTestPage(),
              '/security': (_) => const SecurityPage(),
              '/analytics': (_) => const AnalyticsPage(),
              '/saved': (_) => const SavedPage(),
              '/filter': (_) => const FilterPage(),
              '/radar': (_) => const RadarPage(),
              '/settings': (_) => const SettingsPage(),
              '/tips': (_) => const TipsPage(),
            },
          );
        },
      ),
    );
  }
}
