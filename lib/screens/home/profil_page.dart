import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../screens/edit_profile_page.dart';
import '../../screens/home/riwayat_laporan.dart';
import '../../screens/home/donasi_info_page.dart';
import '../../screens/home/riwayat_donasi.dart';
import '../../screens/home/edit_pass.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _userName = '';
  String _userEmail = '';
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await DatabaseHelper.instance.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userData = user;
        _userName = user['name'] as String;
        _userEmail = user['email'] as String;
      });
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
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (_userData?['image_path'] != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: InteractiveViewer(
                            child: Image.file(
                              File(_userData!['image_path']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _userData?['image_path'] != null
                    ? FileImage(File(_userData!['image_path'])) as ImageProvider
                    : null,
                child: _userData?['image_path'] == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
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
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Ubah Profil',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                if (result == true) {
                  _loadUserData();
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Ubah kata sandi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditPassPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Riwayat Laporan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiwayatLaporanPage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.monetization_on_outlined,
              title: 'Riwayat Donasi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatDonasiPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah yakin ingin keluar dari aplikasi Lapor.in?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Ya'),
                          onPressed: () {
                            DatabaseHelper.instance.setCurrentUserEmail(null);
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                        ),
                      ],
                    );
                  },
                );
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
