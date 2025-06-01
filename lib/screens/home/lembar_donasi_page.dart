import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/database_helper.dart';

class LembarDonasiPage extends StatefulWidget {
  final String reportTitle;
  final String userEmail;
  final int reportId;

  const LembarDonasiPage({
    Key? key,
    required this.reportTitle,
    required this.userEmail,
    this.reportId = 0,
  }) : super(key: key);

  @override
  _LembarDonasiPageState createState() => _LembarDonasiPageState();
}

class _LembarDonasiPageState extends State<LembarDonasiPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _pesanController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  int? _selectedNominal;
  bool _isLainnyaSelected = false;
  String? _selectedPaymentMethod;

  final List<int> _nominalOptions = [10000, 50000, 100000];

  @override
  void dispose() {
    _namaController.dispose();
    _pesanController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  bool get _isBayarEnabled {
    if (_isLainnyaSelected) {
      final val = int.tryParse(_nominalController.text.replaceAll('.', '').replaceAll(',', ''));
      return val != null && val > 0 && val <= 5000000 && _selectedPaymentMethod != null;
    } else {
      return _selectedNominal != null && _selectedPaymentMethod != null;
    }
  }

  void _onNominalSelected(int? value) {
    setState(() {
      _selectedNominal = value;
      _isLainnyaSelected = false;
      _nominalController.clear();
    });
  }

  void _onLainnyaSelected() {
    setState(() {
      _selectedNominal = null;
      _isLainnyaSelected = true;
    });
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _onBayarPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah anda yakin melakukan transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _saveDonationToDatabase();
              _showSuccessDialog();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDonationToDatabase() async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // Get current user by email
      final user = await dbHelper.getUserByEmail(widget.userEmail);
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }
      final userId = user['id'] as int;

      // Determine nominal
      int nominal;
      if (_isLainnyaSelected) {
        nominal = int.parse(_nominalController.text.replaceAll('.', '').replaceAll(',', ''));
      } else {
        nominal = _selectedNominal ?? 0;
      }

      // Prepare donation data
      final donationData = {
        'user_id': userId,
        'report_id': widget.reportId,
        'nominal': nominal,
        'pesan': _pesanController.text,
        'name': _namaController.text.trim(),
        'metode_pembayaran': _selectedPaymentMethod ?? '',
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Debug: Donation data to insert: $donationData'); // Debug print

      await dbHelper.insertDonation(donationData);
      print('Donation saved successfully');
    } catch (e) {
      print('Error saving donation: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: const Text('Pembayaran berhasil dilakukan.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Close LembarDonasiPage and return true
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildNominalButton(int value) {
    final isSelected = _selectedNominal == value && !_isLainnyaSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF001F53),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => _onNominalSelected(value),
        child: Text(
          'Rp${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLainnyaButton() {
    final isSelected = _isLainnyaSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF001F53),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _onLainnyaSelected,
        child: const Text(
          'Lainnya',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method, String label, Widget icon) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () => _onPaymentMethodSelected(method),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF1E40AF) : Colors.grey, width: isSelected ? 3.0 : 1.0),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.userEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F53),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lembar Donasi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '"${widget.reportTitle}"',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Container 1: Lembar Identitas
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lembar Identitas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _namaController,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Nama (Opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: false,
                        controller: TextEditingController(text: email),
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pesanController,
                        maxLines: 3,
                        maxLength: 35,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Pesan (Opsional)',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),
                // Container 2: Nominal Donasi
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nominal Donasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildNominalButton(_nominalOptions[0]),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildNominalButton(_nominalOptions[1]),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildNominalButton(_nominalOptions[2]),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _buildLainnyaButton(),
                          ),
                        ],
                      ),
                      if (_isLainnyaSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: TextField(
                            controller: _nominalController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ThousandsSeparatorInputFormatter(),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Nominal Donasi',
                              border: OutlineInputBorder(),
                              prefixText: 'Rp ',
                              hintText: 'Masukkan nominal (max 5.000.000)',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Container 3: Metode Pembayaran
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'E-wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      _buildPaymentMethodButton(
                        'dana',
                        'DANA',
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _selectedPaymentMethod == 'dana' ? const Color(0xFF1E40AF) : Colors.grey),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/Dana.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      _buildPaymentMethodButton(
                        'shopeepay',
                        'ShopeePay',
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _selectedPaymentMethod == 'shopeepay' ? const Color(0xFF1E40AF) : Colors.grey),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/Spay.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      _buildPaymentMethodButton(
                        'bank_transfer',
                        'Bank Transfer',
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _selectedPaymentMethod == 'bank_transfer' ? const Color(0xFF1E40AF) : Colors.grey),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/Transfer.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      _buildPaymentMethodButton(
                        'bni_va',
                        'BNI Virtual Account',
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _selectedPaymentMethod == 'bni_va' ? const Color(0xFF1E40AF) : Colors.grey),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/BNI.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBayarEnabled ? _onBayarPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBayarEnabled ? const Color(0xFFD4A24C) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Bayar',
                  style: TextStyle(
                    color: Color(0xFF001F53),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('.', '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    int value = int.parse(newText);
    final formatter = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String newString = value.toString().replaceAllMapped(formatter, (match) => '.');

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
