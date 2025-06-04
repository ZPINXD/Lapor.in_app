import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class EditLaporanAdminPage extends StatefulWidget {
  const EditLaporanAdminPage({Key? key}) : super(key: key);

  @override
  _EditLaporanAdminPageState createState() => _EditLaporanAdminPageState();
}

class _EditLaporanAdminPageState extends State<EditLaporanAdminPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  String? _filterStatus;
  DateTime? _filterDate;

  final List<String> _statusOptions = ['pending', 'proses', 'selesai', 'dibatalkan'];

  // Map untuk menyimpan selectedStatus per laporan (key: reportId)
  Map<int, String> _selectedStatuses = {};

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
      final reports = await DatabaseHelper.instance.getAllReports(
        status: _filterStatus,
        date: _filterDate,
      );
      setState(() {
        _reports = reports;
        // Reset selectedStatuses sesuai laporan yang baru dimuat
        _selectedStatuses = {
          for (var report in reports) report['id'] as int: report['status'] as String? ?? 'pending'
        };
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

  // Fungsi untuk mendapatkan opsi status yang valid untuk dropdown sesuai alur maju
  List<String> _getValidStatusOptions(String currentStatus) {
    final index = _statusOptions.indexOf(currentStatus);
    if (index == -1) return _statusOptions;
    List<String> options = _statusOptions.sublist(index);
    // Jika status saat ini adalah 'selesai', hilangkan opsi 'dibatalkan'
    if (currentStatus == 'selesai') {
      options = options.where((status) => status != 'dibatalkan').toList();
    }
    return options;
  }

  // Fungsi untuk mengupdate status laporan
  Future<void> _updateStatus(int reportId, String newStatus) async {
    try {
      await DatabaseHelper.instance.updateReportStatus(reportId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status laporan berhasil diperbarui')),
      );
      await _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  // Widget untuk filter status
  Widget _buildStatusFilter() {
    return DropdownButton<String>(
      hint: const Text('Filter Status', style: TextStyle(color: Colors.white)),
      dropdownColor: const Color(0xFF001F53),
      value: _filterStatus,
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white,
      items: [null, ..._statusOptions].map((status) {
        if (status == null) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(
              'Semua',
              style: const TextStyle(color: Colors.white),
            ),
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
              Text(
                status,
                style: const TextStyle(color: Colors.white),
              ),
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

  // Widget untuk filter tanggal
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

  // Widget untuk menampilkan item laporan
  Widget _buildReportItem(Map<String, dynamic> report) {
    final currentStatus = report['status'] as String? ?? 'pending';
    final validStatusOptions = _getValidStatusOptions(currentStatus);
    // Ambil selectedStatus dari state _selectedStatuses
    String? selectedStatus = _selectedStatuses[report['id'] as int] ?? currentStatus;

    Color borderColor;
    switch (selectedStatus) {
      case 'pending':
        borderColor = Colors.grey;
        break;
      case 'proses':
        borderColor = Colors.amber;
        break;
      case 'selesai':
        borderColor = Colors.green;
        break;
      case 'dibatalkan':
        borderColor = Colors.red;
        break;
      default:
        borderColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deskripsi: ${report['description'] ?? '-'}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Pelapor: ${report['reporter_name'] ?? '-'}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${report['formatted_date'] ?? '-'}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            if (report['image_path'] != null && report['image_path'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () {
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
                              child: SizedBox(
                                width: 400,
                                height: 400,
                                child: Image.file(
                                  File(report['image_path']),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Image.file(
                    File(report['image_path']),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(color: Colors.black87),
                ),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: validStatusOptions.map((status) {
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
                          Text(status),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null && value != selectedStatus) {
                      setState(() {
                        // Update selectedStatus di state _selectedStatuses
                        _selectedStatuses[report['id'] as int] = value;
                      });
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A24C),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (selectedStatus != currentStatus) {
                      _updateStatus(report['id'] as int, selectedStatus!);
                    }
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
        iconTheme: const IconThemeData(color: Colors.white), // Membuat tombol kembali berwarna putih
        title: const Text(
          'Edit Laporan Admin',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF001F53),
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
                Row(
                  children: [
                    _buildDateFilter(),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
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
