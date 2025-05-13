import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../db/database_helper.dart';
import '../../models/report_form_data.dart';
import '../../widgets/step_indicator.dart';

class LaporPage extends StatefulWidget {
  const LaporPage({Key? key}) : super(key: key);

  @override
  _LaporPageState createState() => _LaporPageState();
}

class _LaporPageState extends State<LaporPage> {
  final _formKey = GlobalKey<FormState>();
  final _reportData = ReportFormData();
  int _currentStep = 1;
  bool _isLoading = false;
  bool _isLoadingCities = false; // Menambahkan state untuk loading kota

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  // Data lists
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _agencies = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provinces = await DatabaseHelper.instance.getAllProvinces();
      final categories = await DatabaseHelper.instance.getAllCategories();
      final agencies = await DatabaseHelper.instance.getAllAgencies();

      if (mounted) {
        setState(() {
          _provinces = List<Map<String, dynamic>>.from(provinces);
          _categories = List<Map<String, dynamic>>.from(categories);
          _agencies = List<Map<String, dynamic>>.from(agencies);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCities(int provinceId) async {
    setState(() {
      _isLoadingCities = true;
    });

    try {
      final cities = await DatabaseHelper.instance.getCitiesByProvince(provinceId);
      if (mounted) {
        setState(() {
          _cities = List<Map<String, dynamic>>.from(cities);
          _reportData.cityId = null;
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data kota: $e')),
        );
        setState(() {
          _isLoadingCities = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ukuran file maksimal 5MB')),
          );
        }
        return;
      }

      setState(() {
        _reportData.imagePath = file.path;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_reportData.isStep3Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang pernyataan kebenaran laporan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseHelper.instance.getCurrentUser();
      if (user == null) throw Exception('User tidak ditemukan');

      final report = await DatabaseHelper.instance.createReport(
        userId: user['id'] as int,
        title: _reportData.title!,
        description: _reportData.description!,
        provinceId: _reportData.provinceId!,
        cityId: _reportData.cityId!,
        address: _reportData.address!,
        categoryId: _reportData.categoryId!,
        agencyId: _reportData.agencyId!,
        imagePath: _reportData.imagePath,
        isAnonymous: _reportData.isAnonymous,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        // Tampilkan snackbar sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dikirim'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Tunggu snackbar selesai sebelum navigasi
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Navigate to main screen with beranda tab
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
                (route) => false,
            arguments: {'initialIndex': 0}, // 0 adalah index beranda
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<Map<String, dynamic>> items,
    required int? value,
    required Function(int?) onChanged,
    bool isLoading = false,
    String? Function(int?)? validator,
  }) {
    final bool isDisabled = items.isEmpty && !isLoading && value == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: isLoading ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A24C)),
              ),
            ),
          ) : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isLoading ? 'Sedang memuat data...' : 'Pilih provinsi terlebih dahulu'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              } : null,
              child: IgnorePointer(
                ignoring: isDisabled,
                child: DropdownButtonFormField<int>(
                  value: value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFD4A24C)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  hint: Text(hint, style: const TextStyle(color: Colors.grey)),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item['id'] as int,
                      child: Text(
                        item['name'] as String,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  validator: validator,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown Provinsi
            _buildDropdown(
              label: 'Provinsi',
              hint: 'Pilih Provinsi',
              items: _provinces,
              value: _reportData.provinceId,
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _reportData.provinceId = value;
                    _cities.clear();
                    _reportData.cityId = null;
                  });
                  await _loadCities(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Provinsi harus dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dropdown Kota/Kabupaten
            _buildDropdown(
              label: 'Kota/Kabupaten',
              hint: 'Pilih Kota/Kabupaten',
              items: _cities,
              value: _reportData.cityId,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _reportData.cityId = value;
                  });
                }
              },
              isLoading: _isLoadingCities,
              validator: (value) {
                if (value == null) {
                  return 'Kota/Kabupaten harus dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Alamat
            const Text(
              'Alamat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Colors.black), // Menambahkan warna text input
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) => _reportData.address = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Judul Laporan
            const Text(
              'Judul Laporan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black), // Menambahkan warna text input
              decoration: InputDecoration(
                hintText: 'Masukkan judul laporan',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) => _reportData.title = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.black), // Menambahkan warna text input
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi laporan',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) => _reportData.description = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Upload Bukti
            const Text(
              'Unggah Bukti',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _reportData.imagePath == null
                  ? InkWell(
                onTap: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.cloud_upload,
                      size: 50,
                      color: Color(0xFFD4A24C),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Klik untuk unggah gambar\n(Maks. 5MB)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : Stack(
                children: [
                  Image.file(
                    File(_reportData.imagePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _reportData.imagePath = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mode Pelaporan
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _reportData.isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _reportData.isAnonymous = value!;
                    });
                  },
                ),
                const Text(
                  'Publik',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(width: 16),
                Radio<bool>(
                  value: true,
                  groupValue: _reportData.isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _reportData.isAnonymous = value!;
                    });
                  },
                ),
                const Text(
                  'Anonim',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori
          const Text(
            'Kategori Laporan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<int>(
              value: _reportData.categoryId,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              hint: const Text(
                'Pilih Kategori',
                style: TextStyle(color: Colors.grey),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category['id'] as int,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _reportData.categoryId = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Instansi Tujuan
          const Text(
            'Instansi Tujuan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<int>(
              value: _reportData.agencyId,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              hint: const Text(
                'Pilih Instansi',
                style: TextStyle(color: Colors.grey),
              ),
              items: _agencies.map((agency) {
                return DropdownMenuItem(
                  value: agency['id'] as int,
                  child: Text(agency['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _reportData.agencyId = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rangkuman Laporan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),

          // Data Laporan
          _buildSummaryItem(
            'Judul',
            _reportData.title ?? '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Deskripsi',
            _reportData.description ?? '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Lokasi',
            _provinces
                .firstWhere(
                  (p) => p['id'] == _reportData.provinceId,
              orElse: () => {'name': ''},
            )['name']
                ?.toString() ??
                '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Kota/Kabupaten',
            _cities
                .firstWhere(
                  (c) => c['id'] == _reportData.cityId,
              orElse: () => {'name': ''},
            )['name']
                ?.toString() ??
                '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Alamat',
            _reportData.address ?? '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Kategori',
            _categories
                .firstWhere(
                  (c) => c['id'] == _reportData.categoryId,
              orElse: () => {'name': ''},
            )['name']
                ?.toString() ??
                '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Instansi Tujuan',
            _agencies
                .firstWhere(
                  (a) => a['id'] == _reportData.agencyId,
              orElse: () => {'name': ''},
            )['name']
                ?.toString() ??
                '',
            isHeader: true,
          ),
          _buildSummaryItem(
            'Mode Pelaporan',
            _reportData.isAnonymous ? 'Anonim' : 'Publik',
            isHeader: true,
          ),

          if (_reportData.imagePath != null) ...[
            const SizedBox(height: 16),
            _buildSummaryItem(
              'Bukti',
              '',
              isHeader: true,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_reportData.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 24),
          // Checkbox Verifikasi
          Row(
            children: [
              Checkbox(
                value: _reportData.isVerified,
                onChanged: (value) {
                  setState(() {
                    _reportData.isVerified = value!;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Dengan ini saya menyatakan bahwa laporan yang saya tulis benar adanya.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isHeader ? 16 : 14,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 1 && !_reportData.isStep1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data yang diperlukan')),
      );
      return;
    }

    if (_currentStep == 2 && !_reportData.isStep2Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dan instansi tujuan')),
      );
      return;
    }

    setState(() {
      if (_currentStep < 3) _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 1) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F53),
        title: const Text(
          'Buat Laporan',
          style: TextStyle(color: Colors.white),
        ),
        leading: _currentStep > 1
            ? IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _previousStep,
        )
            : null,
        automaticallyImplyLeading: false, // Menonaktifkan tombol back default di step 1
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          StepIndicator(
            currentStep: _currentStep,
            totalSteps: 3,
          ),
          Expanded(
            child: _currentStep == 1
                ? _buildStep1()
                : _currentStep == 2
                ? _buildStep2()
                : _buildStep3(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentStep == 3 ? _submitReport : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A24C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _currentStep == 3 ? 'Kirim Laporan' : 'Selanjutnya',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
