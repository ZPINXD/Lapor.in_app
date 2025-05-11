import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F53),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.notifications,
              size: 100,
              color: Color(0xFFD4A24C),
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Notifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001F53),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur dalam pengembangan',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
