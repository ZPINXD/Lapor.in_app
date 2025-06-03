import 'package:flutter/material.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  // Dummy user data
  String fullName = 'John Doe';
  String email = 'johndoe@example.com';
  String phoneNumber = '08123456789';
  String address = 'Jl. Merdeka No. 123, Jakarta';
  String username = 'johndoe';
  String status = 'aktif';

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF001F53);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail User'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User data card
                  Flexible(
                    flex: 3,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nama Lengkap: $fullName', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Email: $email', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Nomor Telepon: $phoneNumber', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Alamat: $address', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Username: $username', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Status dropdown
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                            DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                status = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder for save functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perubahan berhasil disimpan')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
