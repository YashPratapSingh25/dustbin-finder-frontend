import 'package:dustbin_finder/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'framework/core/config/environment.dart';
import 'framework/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ProviderScope(child: DustbinApp()));
  debugPrint('Dustbin Finder environment: ${EnvironmentConfig.name}');
  debugPrint('API base URL: ${EnvironmentConfig.baseUrl}');
}

class DustbinApp extends StatelessWidget {
  const DustbinApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF167D67);
    return MaterialApp(
      title: 'Dustbin Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9F8),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F6F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
