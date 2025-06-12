import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  InputDecoration _getInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD4A24C)),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Fungsi untuk validasi step 1
  Future<bool> _validateStep1() async {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Nama tidak boleh kosong');
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showErrorDialog('Tempat tinggal tidak boleh kosong');
      return false;
    }
    if (_selectedGender == null) {
      _showErrorDialog('Pilih jenis kelamin');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showErrorDialog('Nomor telepon tidak boleh kosong');
      return false;
    }
    if (_phoneController.text.length < 12 || _phoneController.text.length > 13) {
      _showErrorDialog('Nomor telepon harus 12-13 digit');
      return false;
    }

    // Cek apakah nomor telepon sudah terdaftar
    try {
      final existingUser = await DatabaseHelper.instance.getUserByPhone(_phoneController.text);
      if (existingUser != null) {
        _showErrorDialog('Nomor telepon sudah terdaftar');
        return false;
      }
    } catch (error) {
      _showErrorDialog('Error: $error');
      return false;
    }

    return true;
  }

  // Fungsi untuk validasi step 2
  Future<bool> _validateStep2() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Email tidak boleh kosong');
      return false;
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(_emailController.text)) {
      _showErrorDialog('Format email tidak valid');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showErrorDialog('Kata sandi tidak boleh kosong');
      return false;
    }
    if (_confirmController.text.isEmpty) {
      _showErrorDialog('Konfirmasi kata sandi tidak boleh kosong');
      return false;
    }
    if (_passwordController.text != _confirmController.text) {
      _showErrorDialog('Kata sandi dan konfirmasi kata sandi tidak sama');
      return false;
    }

    // Cek apakah email sudah terdaftar
    try {
      final existingUser = await DatabaseHelper.instance.getUserByEmail(_emailController.text);
      if (existingUser != null) {
        _showErrorDialog('Email sudah terdaftar');
        return false;
      }
    } catch (error) {
      _showErrorDialog('Error: $error');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFD4A24C)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final existingUser = await DatabaseHelper.instance.getUserByEmail(_emailController.text);
        if (existingUser != null) {
          _showErrorDialog('Email sudah terdaftar');
        } else {
          Map<String, dynamic> user = {
            'name': _nameController.text,
            'address': _addressController.text,
            'gender': _selectedGender,
            'phone': _phoneController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          };
          await DatabaseHelper.instance.registerUser(user);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrasi berhasil. Silakan login!'),
                backgroundColor: Color(0xFFD4A24C),
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (error) {
        if (mounted) {
          _showErrorDialog('Error: $error');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildDataDiriStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.black),
          decoration: _getInputDecoration('Nama Lengkap', 'Masukkan nama lengkap...'),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          style: const TextStyle(color: Colors.black),
          decoration: _getInputDecoration('Tempat Tinggal', 'Masukkan tempat tinggal...'),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.streetAddress,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          style: const TextStyle(color: Colors.black),
          decoration: _getInputDecoration('Jenis Kelamin', ''),
          items: const [
            DropdownMenuItem(
              value: 'Laki-laki',
              child: Text('Laki-laki', style: TextStyle(color: Colors.black)),
            ),
            DropdownMenuItem(
              value: 'Perempuan',
              child: Text('Perempuan', style: TextStyle(color: Colors.black)),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          style: const TextStyle(color: Colors.black),
          decoration: _getInputDecoration('Nomor Telepon', 'Masukkan nomor telepon...'),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          style: const TextStyle(color: Colors.black),
          decoration: _getInputDecoration('Email', 'Masukkan email...'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          style: const TextStyle(color: Colors.black),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: _getInputDecoration('Kata Sandi', 'Masukkan kata sandi...').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmController,
          style: const TextStyle(color: Colors.black),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: _getInputDecoration('Konfirmasi Kata Sandi', 'Konfirmasi kata sandi...').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  final List<TextEditingController> _otpControllers = List.generate(4, (index) => TextEditingController());

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Kode Verifikasi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kami telah mengirim kode verifikasi ke email anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 50,
              child: TextFormField(
                controller: _otpControllers[index],
                style: const TextStyle(color: Colors.black, fontSize: 24),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD4A24C)),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 3) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            // TODO: Implement resend verification code
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kode verifikasi telah dikirim ulang'),
                backgroundColor: Color(0xFFD4A24C),
              ),
            );
          },
          child: const Text(
            'Kirim ulang kode?',
            style: TextStyle(color: Color(0xFFD4A24C)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A24C)),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Kembali',
          style: TextStyle(color: Color(0xFFD4A24C)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Selamat Datang di ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Lapor.in',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4A24C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Data diri'),
                  _buildStepConnector(0),
                  _buildStepIndicator(1, 'Email'),
                  _buildStepConnector(1),
                  _buildStepIndicator(2, 'Verifikasi'),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _currentStep == 0
                      ? _buildDataDiriStep()
                      : _currentStep == 1
                      ? _buildEmailStep()
                      : _buildVerificationStep(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_currentStep == 0) {
                        if (await _validateStep1()) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      } else if (_currentStep == 1) {
                        if (await _validateStep2()) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      } else {
                        _register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A24C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _currentStep < 2 ? 'Lanjutkan' : 'Daftar',
                      style: const TextStyle(
                        color: Color(0xFF001F53),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD4A24C) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFD4A24C) : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    bool isActive = step < _currentStep;
    return Container(
      width: 60,
      height: 2,
      color: isActive ? const Color(0xFFD4A24C) : Colors.grey[300],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
