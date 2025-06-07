import 'package:flutter/material.dart';
import 'screens/user_detail_page.dart';
import 'screens/edit_landing_page.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_page.dart';
import 'screens/lupapass_page.dart';
import 'screens/instansi_admin_page.dart';


final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => const SplashScreen(),
  '/landing': (context) => const LandingPage(),
  '/edit-landing': (context) => const EditLandingPage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/instansi': (context) => const InstansiAdminPage(),
  '/main': (context) => const MainScreen(), // Menggunakan MainScreen sebagai container untuk semua halaman home
  '/admin': (context) => const AdminPage(), // Menambahkan route untuk halaman admin
  '/lupapass': (context) => const LupaPasswordPage(), // Menambahkan route untuk halaman lupa password
};
