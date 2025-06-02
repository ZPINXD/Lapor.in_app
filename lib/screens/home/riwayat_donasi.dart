import 'dart:io';

import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import 'donasi_info_page.dart';

class RiwayatDonasiPage extends StatefulWidget {
  const RiwayatDonasiPage({Key? key}) : super(key: key);

  @override
  _RiwayatDonasiPageState createState() => _RiwayatDonasiPageState();
}

class _RiwayatDonasiPageState extends State<RiwayatDonasiPage> {
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await DatabaseHelper.instance.getCurrentUser();
      if (user == null) throw Exception('User tidak ditemukan');

      // Query gabungan donasi, laporan, dan data pelapor
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('''
        SELECT d.*, r.title, r.description, r.created_at as report_created_at,
               r.is_anonymous, u.name as reporter_name, u.image_path as reporter_image,
               p.name as province_name, c.name as city_name,
               COALESCE(r.address, '') as address
        FROM donations d
        JOIN reports r ON d.report_id = r.id
        JOIN users u ON r.user_id = u.id
        LEFT JOIN provinces p ON r.province_id = p.id
        LEFT JOIN cities c ON r.city_id = c.id
        WHERE d.user_id = ?
        ORDER BY d.created_at DESC
      ''', [user['id']]);

      setState(() {
        _donations = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat riwayat donasi: $e')),
      );
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day.toString().padLeft(2, '0')} '
          '${_monthName(dateTime.month)} '
          '${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final reporterName = donation['is_anonymous'] == 1 ? 'Anonim' : (donation['reporter_name'] ?? 'Anonim');
    final reporterImage = donation['reporter_image'] as String?;
    final reportDate = donation['report_created_at'] ?? '';
    final location = (donation['province_name'] ?? '') + (donation['city_name'] != null ? ', ' + donation['city_name'] : '');
    final title = donation['title'] ?? '-';
    final description = donation['description'] ?? '-';
    final donorName = (donation['name'] ?? '').toString().trim().isEmpty ? 'Anonim' : donation['name'];
    final amount = donation['nominal'] ?? 0;
    final pesan = (donation['pesan'] ?? '').toString().trim().isEmpty ? '-' : donation['pesan'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Foto profil pelapor (jika ada), jika tidak inisial nama
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF001F53),
                  backgroundImage: reporterImage != null && reporterImage.isNotEmpty
                      ? (reporterImage.startsWith('http') || reporterImage.startsWith('https')
                      ? NetworkImage(reporterImage)
                      : FileImage(File(reporterImage)) as ImageProvider)
                      : null,
                  child: (reporterImage == null || reporterImage.isEmpty)
                      ? Text(
                    reporterName.isNotEmpty ? reporterName[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reporterName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      Text(
                        _formatDate(reportDate),
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      Text(
                        'Lokasi: $location',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye, color: Color(0xFF001F53)),
                  onPressed: () async {
                    final db = await DatabaseHelper.instance.database;
                    final reportId = donation['report_id'] as int;
                    final reportList = await db.rawQuery('''
                      SELECT r.*, u.name as reporter_name, u.image_path as reporter_image
                      FROM reports r
                      LEFT JOIN users u ON r.user_id = u.id
                      WHERE r.id = ?
                    ''', [reportId]);
                    final report = reportList.isNotEmpty ? Map<String, dynamic>.from(reportList.first) : <String, dynamic>{};
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonasiInfoPage(
                          report: report,
                          userEmail: '', // Bisa diisi sesuai kebutuhan
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001F53)),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: 'Telah berdonasi sebesar ',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(
                    text: 'Rp${amount.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                  const TextSpan(text: ' dengan nama '),
                  TextSpan(
                    text: donorName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal donasi: ${_formatDate(donation['created_at'] ?? '')}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'dengan pesan: $pesan',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Donasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF001F53),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
          ? const Center(child: Text('Tidak ada riwayat donasi'))
          : ListView.builder(
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          return _buildDonationCard(_donations[index]);
        },
      ),
    );
  }
}
