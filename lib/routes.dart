import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => const SplashScreen(),
  '/landing': (context) => const LandingPage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/main': (context) => const MainScreen(), // Menggunakan MainScreen sebagai container untuk semua halaman home
};
