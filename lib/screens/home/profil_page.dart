import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('Loading user data in ProfilPage...'); // Debug print
    final user = await DatabaseHelper.instance.getCurrentUser();
    print('User data received in ProfilPage: $user'); // Debug print
    if (user != null && mounted) {
      setState(() {
        _userName = user['name'] as String;
        _userEmail = user['email'] as String;
        print('Username set to: $_userName'); // Debug print
        print('Email set to: $_userEmail'); // Debug print
      });
    } else {
      print('No user data available or widget unmounted'); // Debug print
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF001F53)),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF001F53),
          fontSize: 16,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF001F53),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F53),
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001F53),
              ),
            ),
            Text(
              _userEmail,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profil',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Riwayat Laporan',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                // Clear current user data
                DatabaseHelper.instance.setCurrentUserEmail(null);
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
