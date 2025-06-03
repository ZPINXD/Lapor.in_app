import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/database_helper.dart';

class RiwayatLaporanPage extends StatefulWidget {
  const RiwayatLaporanPage({Key? key}) : super(key: key);

  @override
  _RiwayatLaporanPageState createState() => _RiwayatLaporanPageState();
}

class _RiwayatLaporanPageState extends State<RiwayatLaporanPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  String? _filterStatus;
  DateTime? _filterDate;

  final List<String> _statusOptions = ['pending', 'proses', 'selesai', 'dibatalkan'];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await DatabaseHelper.instance.getCurrentUser();
      if (user == null) throw Exception('User tidak ditemukan');

      final reports = await DatabaseHelper.instance.getReportsByUser(user['id'] as int);
      // Apply filters manually since getReportsByUser does not support filters
      List<Map<String, dynamic>> filteredReports = reports;

      if (_filterStatus != null && _filterStatus!.isNotEmpty) {
        filteredReports = filteredReports.where((r) => r['status'] == _filterStatus).toList();
      }
      if (_filterDate != null) {
        filteredReports = filteredReports.where((r) {
          final createdAt = DateTime.tryParse(r['created_at'] ?? '');
          if (createdAt == null) return false;
          return createdAt.year == _filterDate!.year &&
              createdAt.month == _filterDate!.month &&
              createdAt.day == _filterDate!.day;
        }).toList();
      }

      setState(() {
        _reports = filteredReports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat laporan: $e')),
      );
    }
  }

  Future<void> _cancelReport(int reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text('Apakah Anda yakin ingin membatalkan laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.updateReportStatus(reportId, 'dibatalkan');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dibatalkan')),
        );
        _loadReports();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan laporan: $e')),
        );
      }
    }
  }

  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      dropdownColor: const Color(0xFF001F53),
      hint: const Text('Filter Status', style: TextStyle(color: Colors.white)),
      value: _filterStatus,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: [null, ..._statusOptions].map((status) {
        if (status == null) {
          return const DropdownMenuItem<String>(
            value: null,
            child: Text('Semua', style: TextStyle(color: Colors.white)),
          );
        }
        Color iconColor;
        switch (status) {
          case 'pending':
            iconColor = Colors.grey;
            break;
          case 'proses':
            iconColor = Colors.amber;
            break;
          case 'selesai':
            iconColor = Colors.green;
            break;
          case 'dibatalkan':
            iconColor = Colors.red;
            break;
          default:
            iconColor = Colors.grey;
        }
        return DropdownMenuItem<String>(
          value: status,
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: iconColor),
              const SizedBox(width: 8),
              Text(status, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _filterStatus = value;
        });
        _loadReports();
      },
    );
  }

  Widget _buildDateFilter() {
    return TextButton(
      child: Text(
        _filterDate == null ? 'Filter Tanggal' : _filterDate!.toLocal().toString().split(' ')[0],
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _filterDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _filterDate = picked;
          });
          _loadReports();
        }
      },
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final status = report['status'] as String? ?? 'pending';
    final createdAt = report['created_at'] ?? '';
    final title = report['title'] ?? 'No Title';
    final description = report['description'] ?? '-';
    final imagePath = report['image_path'] as String?;
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.grey;
        break;
      case 'proses':
        statusColor = Colors.amber;
        break;
      case 'selesai':
        statusColor = Colors.green;
        break;
      case 'dibatalkan':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Tanggal: ${_formatDate(createdAt)}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            if (imagePath != null && imagePath.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (status == 'pending')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A24C),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _cancelReport(report['id'] as int),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day.toString().padLeft(2, '0')} '
          '${_monthName(dateTime.month)} '
          '${dateTime.year}, '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Laporan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF001F53),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildStatusFilter(),
                const SizedBox(width: 24),
                _buildDateFilter(),
                if (_filterDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Reset Filter Tanggal',
                    onPressed: () {
                      setState(() {
                        _filterDate = null;
                      });
                      _loadReports();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _reports.isEmpty
                ? const Center(child: Text('Tidak ada laporan'))
                : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                return _buildReportItem(_reports[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
