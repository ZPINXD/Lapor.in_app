import 'package:flutter/material.dart';
import 'home/beranda_page.dart';
import 'home/donasi_page.dart';
import 'home/lapor_page.dart';
import 'home/notifikasi_page.dart';
import 'home/profil_page.dart';
import '../../db/database_helper.dart';
import '../../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver, RouteAware {
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;

  final List<Widget> _screens = [
    const BerandaPage(),
    const DonasiPage(),
    const LaporPage(),
    const NotifikasiPage(),
    const ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    _fetchUnreadNotificationCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUnreadNotificationCount();
    }
  }

  @override
  void didPopNext() {
    // Called when the current route is shown again after popping a route above it
    _fetchUnreadNotificationCount();
  }

  Future<void> _fetchUnreadNotificationCount() async {
    final dbHelper = DatabaseHelper.instance;
    final currentUser = await dbHelper.getCurrentUser();
    if (currentUser != null) {
      final userId = currentUser['id'] as int;
      final count = await dbHelper.getUnreadNotificationCount(userId);
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 3) {
            // When navigating to notifications, mark all as read and reset unread count
            final dbHelper = DatabaseHelper.instance;
            final currentUser = await dbHelper.getCurrentUser();
            if (currentUser != null) {
              final userId = currentUser['id'] as int;
              await dbHelper.markAllNotificationsAsRead(userId);
            }
            setState(() {
              _unreadNotificationCount = 0;
            });
          }
          // Refresh unread notification count on tab change
          await _fetchUnreadNotificationCount();
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donasi',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C38FF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            label: 'Lapor',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: const Color(0xFFD4A24C),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
