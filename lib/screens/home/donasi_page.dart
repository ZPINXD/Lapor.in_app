import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import 'package:intl/intl.dart';
import '../../screens/home/donasi_info_page.dart';

class DonasiPage extends StatefulWidget {
  const DonasiPage({Key? key}) : super(key: key);

  @override
  _DonasiPageState createState() => _DonasiPageState();
}

class _DonasiPageState extends State<DonasiPage> {
  List<Map<String, dynamic>> _bencanaReports = [];
  bool _isLoading = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadBencanaReports();
    _loadCurrentUserEmail();
  }

  Future<void> _loadCurrentUserEmail() async {
    final user = await DatabaseHelper.instance.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userEmail = user['email'] as String;
      });
    }
  }

  Future<void> _loadBencanaReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper.instance;

      // Ambil kategori bencana dari database
      final categories = await dbHelper.getAllCategories();
      final bencanaCategory = categories.firstWhere(
            (cat) => cat['name'].toString().toLowerCase().contains('bencana'),
        orElse: () => {},
      );

      if (bencanaCategory.isEmpty) {
        setState(() {
          _bencanaReports = [];
          _isLoading = false;
        });
        return;
      }

      // Ambil laporan dengan status 'proses' dan 'selesai'
      final reportsProses = await dbHelper.getAllReports(categoryId: bencanaCategory['id'], status: 'proses');
      final reportsSelesai = await dbHelper.getAllReports(categoryId: bencanaCategory['id'], status: 'selesai');
      final reports = [...reportsProses, ...reportsSelesai];
      setState(() {
        _bencanaReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bencana reports: $e');
      setState(() {
        _bencanaReports = [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      final formatter = DateFormat('dd MMM yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Donasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF001F53),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bencanaReports.isEmpty
          ? const Center(
        child: Text(
          'Belum ada laporan bencana',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _bencanaReports.length,
        itemBuilder: (context, index) {
          final report = _bencanaReports[index];
          final reporterName = report['reporter_name'] ?? 'Anonymous';
          final reporterImage = report['user_image_path'];
          final date = _formatDate(report['created_at'] ?? '');
          final title = report['title'] ?? '';
          final description = report['description'] ?? '';
          final location = report['city_name'] ?? '';
          final imagePath = report['image_path'];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: (reporterImage != null && reporterImage.isNotEmpty)
                                  ? (reporterImage.startsWith('http') || reporterImage.startsWith('https')
                                  ? NetworkImage(reporterImage)
                                  : FileImage(File(reporterImage)) as ImageProvider)
                                  : null,
                              child: (reporterImage == null || reporterImage.isEmpty)
                                  ? Text(
                                reporterName.isNotEmpty ? reporterName[0].toUpperCase() : 'A',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reporterName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                // Removed inline badge here as per user feedback
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Removed badge here, will add as Positioned
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lokasi: $location',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (imagePath != null && imagePath.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: (imagePath.startsWith('http') || imagePath.startsWith('https'))
                                      ? Image.network(
                                    imagePath,
                                    fit: BoxFit.contain,
                                  )
                                      : Image.file(
                                    File(imagePath),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                            child: (imagePath.startsWith('http') || imagePath.startsWith('https'))
                                ? Image.network(
                              imagePath,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.broken_image)),
                              ),
                            )
                                : Image.file(
                              File(imagePath),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A24C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DonasiInfoPage(
                                      report: report,
                                      userEmail: _userEmail,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                report['status'] == 'selesai' ? 'Lihat Detail' : 'Donasi',
                                style: const TextStyle(color: Color(0xFF001F53)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (report['status'] == 'selesai')
                  Positioned(
                    top: 20,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9F0E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Selesai',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
