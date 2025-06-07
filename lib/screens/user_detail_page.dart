import 'package:flutter/material.dart';
import 'dart:io';
import '../db/database_helper.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({Key? key}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final Color primaryColor = const Color(0xFF001F53);
  List<Map<String, dynamic>> users = [];
  Map<int, String> userStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      users = data;
      for (var user in users) {
        userStatuses[user['id'] as int] = user['status'] ?? 'aktif'; // use actual status from DB
      }
    });
  }

  void _showImagePreview(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar User',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: users.isEmpty
            ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        )
            : ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final userId = user['id'] as int;
            final imagePath = user['image_path'] as String?;
            final status = userStatuses[userId] ?? 'aktif';

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: status == 'aktif' ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (imagePath != null && imagePath.isNotEmpty) {
                          _showImagePreview(imagePath);
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: (imagePath != null && imagePath.isNotEmpty)
                            ? FileImage(File(imagePath))
                            : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                        backgroundColor: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${user['email'] ?? ''}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Nomor Telepon: ${user['phone'] ?? ''}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Alamat: ${user['address'] ?? ''}',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: status,
                          items: [
                            DropdownMenuItem(
                              value: 'aktif',
                              child: Text(
                                'Aktif',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'nonaktif',
                              child: Text(
                                'Nonaktif',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                userStatuses[userId] = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Placeholder for save functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perubahan berhasil disimpan')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2AE45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

}
