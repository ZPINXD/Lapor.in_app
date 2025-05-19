import 'dart:io';
import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import 'package:intl/intl.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({Key? key}) : super(key: key);

  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final List<Map<String, dynamic>> _statusColors = [
    {'status': 'proses', 'color': const Color(0xFFF59E0B), 'text': 'Diproses'},
    {'status': 'selesai', 'color': const Color(0xFF10B981), 'text': 'Selesai'},
  ];

  String? _selectedStatus;
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic>? _currentUser;
  List<Map<DateTime, int>> _timelineData = [];

  bool _hasShownSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasShownSuccessMessage) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showSuccessMessage'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dikirim'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _hasShownSuccessMessage = true;
          // Navigate to same route without arguments to clear them
          Navigator.of(context).pushReplacementNamed('/main');
        });
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load user data
      final user = await DatabaseHelper.instance.getCurrentUser();

      // Load reports with status 'proses' and 'selesai' only
      final reports = await DatabaseHelper.instance.getAllReports(
        statuses: ['proses', 'selesai'],
      );

      // Load timeline data
      final db = await DatabaseHelper.instance.database;
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      final timelineResult = await db.rawQuery('''
        SELECT date(created_at) as date, COUNT(*) as count
        FROM reports
        WHERE date(created_at) >= date(?)
        GROUP BY date(created_at)
        ORDER BY date(created_at)
      ''', [lastWeek.toIso8601String()]);

      if (mounted) {
        setState(() {
          _currentUser = user;
          _reports = List<Map<String, dynamic>>.from(reports);
          _timelineData = timelineResult.map((row) {
            return {
              DateTime.parse(row['date'] as String): row['count'] as int
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF001F53),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo dan Sambutan
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Halo ${_currentUser?['name'] ?? 'User'}! ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '👋',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Text(
                            'Lapor',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '.in',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD4A24C),
                            ),
                          ),
                          Text(
                            ' keluhan kamu!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: _currentUser?['image_path'] != null
                      ? FileImage(File(_currentUser!['image_path'])) as ImageProvider
                      : null,
                  child: _currentUser?['image_path'] == null
                      ? Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 32,
                  )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Filter Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Color(0xFF001F53), size: 16),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: _selectedStatus,
                        hint: const Text(
                          'Filter Status',
                          style: TextStyle(fontSize: 12),
                        ),
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF001F53)),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Semua Status',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ..._statusColors.map((status) {
                            Color iconColor = Colors.grey;
                            IconData iconData = Icons.circle;
                            switch (status['status']) {
                              case 'pending':
                                iconColor = Colors.grey;
                                iconData = Icons.circle;
                                break;
                              case 'proses':
                                iconColor = Colors.amber;
                                iconData = Icons.hourglass_top;
                                break;
                              case 'selesai':
                                iconColor = Colors.green;
                                iconData = Icons.check_circle;
                                break;
                              case 'dibatalkan':
                                iconColor = Colors.red;
                                iconData = Icons.cancel;
                                break;
                            }
                            return DropdownMenuItem(
                              value: status['status'] as String,
                              child: Row(
                                children: [
                                  Icon(iconData, size: 14, color: iconColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    status['text'] as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _filterReports();
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF001F53)),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                          _filterReports();
                        }
                      },
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF001F53)),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                          _filterReports();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineChart() {
    if (_timelineData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'Belum ada data laporan',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Laporan Minggu Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _timelineData.map((data) {
                final date = data.keys.first;
                final count = data.values.first;
                final maxCount = _timelineData
                    .map((d) => d.values.first)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble();
                final height = count / maxCount * 80;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A24C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] as String;
    final statusData = _statusColors.firstWhere(
          (s) => s['status'] == status,
      orElse: () => _statusColors.first,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () => _showReportDetail(report),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Laporan
              if (report['image_path'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Builder(
                    builder: (context) {
                      final file = File(report['image_path']);
                      if (!file.existsSync()) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        );
                      }
                      return GestureDetector(
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
                                    child: Image.file(
                                      file,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(
                          file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 12),

              // Informasi Laporan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.report,
                          size: 18,
                          color: Color(0xFF001F53),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          report['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(report['created_at'])),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (statusData['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusData['status'] == 'pending'
                                    ? Icons.circle
                                    : statusData['status'] == 'proses'
                                    ? Icons.hourglass_top
                                    : statusData['status'] == 'selesai'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 14,
                                color: statusData['status'] == 'pending'
                                    ? Colors.grey
                                    : statusData['color'] as Color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusData['text'] as String,
                                style: TextStyle(
                                  color: statusData['status'] == 'pending'
                                      ? Colors.grey
                                      : statusData['color'] as Color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Selengkapnya
                        TextButton(
                          onPressed: () => _showReportDetail(report),
                          child: const Text(
                            'selengkapnya',
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetail(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Laporan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),

              // Content
              _buildDetailItem('Judul', report['title']),
              _buildDetailItem('Deskripsi', report['description']),
              _buildDetailItem('Tanggal', DateFormat('dd/MM/yyyy').format(DateTime.parse(report['created_at']))),
              _buildDetailItem('Lokasi', report['province_name']),
              _buildDetailItem('Kota/Kabupaten', report['city_name']),
              _buildDetailItem('Alamat', report['address']),
              _buildDetailItem('Kategori', report['category_name']),
              _buildDetailItem('Instansi Tujuan', report['agency_name']),
              _buildDetailItem('Pelapor', report['is_anonymous'] == 1
                  ? 'Anonim'
                  : report['reporter_name']),
              _buildDetailItem('Status', _statusColors.firstWhere(
                    (s) => s['status'] == report['status'],
                orElse: () => _statusColors.first,
              )['text'] as String),

              // Gambar
              if (report['image_path'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Bukti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
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
                                child: Image.file(
                                  File(report['image_path']),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Image.file(
                      File(report['image_path']),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _filterReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await DatabaseHelper.instance.getAllReports(
        status: _selectedStatus,
        date: _selectedDate,
      );

      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTimelineChart(),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Text(
                      'Daftar Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : _reports.isEmpty
                ? const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Belum ada laporan',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReportCard(_reports[index]),
                childCount: _reports.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
