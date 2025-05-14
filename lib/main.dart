import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'db/database_helper.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI
  sqfliteFfiInit();
  // Change the default factory
  databaseFactory = databaseFactoryFfi;

  // Reset and migrate database to latest version
  await DatabaseHelper.instance.database;

  runApp(const LaporInApp());
}

class LaporInApp extends StatelessWidget {
  const LaporInApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor.in',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF001F53)),
        scaffoldBackgroundColor: const Color(0xFF001F53),
        fontFamily: 'Sans-serif',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFFD4A24C),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          labelLarge: TextStyle(
            color: Color(0xFF001F53),
            fontWeight: FontWeight.w600,
          ),
        ),
        dialogTheme: DialogTheme(
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A24C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/splash', // Mulai dari splash screen
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
