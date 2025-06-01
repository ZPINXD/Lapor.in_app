import 'dart:io';

import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import 'lembar_donasi_page.dart';

class DonasiInfoPage extends StatefulWidget {
  final Map<String, dynamic> report;
  final String userEmail;

  const DonasiInfoPage({
    Key? key,
    required this.report,
    required this.userEmail,
  }) : super(key: key);

  @override
  _DonasiInfoPageState createState() => _DonasiInfoPageState();
}

class _DonasiInfoPageState extends State<DonasiInfoPage> {
  int totalDonors = 0;
  int totalDonation = 0;
  List<Map<String, dynamic>> donors = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    final dbHelper = DatabaseHelper.instance;
    final reportId = widget.report['id'] as int? ?? 0;

    final donationList = await dbHelper.getDonationsByReport(reportId);
    final total = await dbHelper.getTotalDonationsByReport(reportId);

    print('Debug: Loaded donations count: ${donationList.length}, total: $total'); // Debug print

    setState(() {
      donors = donationList;
      totalDonors = donationList.length;
      totalDonation = total;
    });
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatNumberWithDots(int number) {
    final numberStr = number.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = numberStr.length - 1; i >= 0; i--) {
      buffer.write(numberStr[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.report['image_path'] ?? '';
    final title = widget.report['title'] ?? '';
    final description = widget.report['description'] ?? '';
    final reporterName = widget.report['reporter_name'] ?? 'Anonymous';
    final donationDistribution = widget.report['donation_distribution'] ??
        'Penyaluran donasi akan diinformasikan lebih lanjut oleh admin.';

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F53),
        title: const Text(
          'Informasi donasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Expanded(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath.isNotEmpty
                  ? (imagePath.startsWith('http') || imagePath.startsWith('https')
                  ? Image.network(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ))
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reporterName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2AE45),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, size: 20, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  '$totalDonors Donatur',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Donasi terkumpul: Rp ${_formatNumberWithDots(totalDonation)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Penyaluran donasi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              donationDistribution,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              'List Donasi ($totalDonors)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            donors.isEmpty
                ? const Text('Belum ada donasi')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                final nominal = donor['nominal'] ?? 0;
                final pesan = donor['pesan'] ?? '';
                final createdAt = donor['created_at'] ?? '';
                final donorName = (donor['name'] ?? '').toString().trim().isEmpty ? 'Anonim' : donor['name'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('Rp ${_formatNumberWithDots(nominal)}'),
                      ],
                    ),
                    subtitle: pesan.isNotEmpty ? Text(pesan) : null,
                    trailing: Text(_formatDateTime(createdAt)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: widget.report['status'] == 'selesai'
          ? null
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LembarDonasiPage(
                    reportTitle: title,
                    userEmail: widget.userEmail,
                    reportId: widget.report['id'],
                  ),
                ),
              );
              if (result == true) {
                _loadDonations();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A24C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Donasi',
              style: TextStyle(
                color: Color(0xFF001F53),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
