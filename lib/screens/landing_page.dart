import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  List<String> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload images when the page is revisited
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final imagesData = await DatabaseHelper.instance.getLandingImages();
      setState(() {
        _images = imagesData.map((img) => img['imagePath'] as String).toList();
        _isLoading = false;
      });

      // Start timer after images are loaded
      _startImageTimer();
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _isLoading = false;
        _images = [
          'assets/image_landpage1.jpg',
          'assets/image_landpage2.jpg',
          'assets/image_landpage3.jpg',
        ];
      });
      _startImageTimer();
    }
  }

  void _startImageTimer() {
    // Cancel existing timer if any
    _timer?.cancel();

    // Only start timer if there's more than one image
    if (_images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_images.isEmpty) return;

        // Use modulo operator for smooth rotation
        final nextPage = (_currentPage + 1) % _images.length;

        // Animate to next page if controller is attached
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();  // Safely cancel timer if it exists
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_images.isEmpty) return;

    int previousPage = _currentPage - 1;
    if (previousPage < 0) {
      previousPage = _images.length - 1;
    }
    _pageController.animateToPage(
      previousPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  void _goToNext() {
    if (_images.isEmpty) return;

    int nextPage = _currentPage + 1;
    if (nextPage >= _images.length) {
      nextPage = 0;
    }
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD4A24C) : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.error, color: Colors.red));
        },
      );
    }
  }

  List<Widget> _buildPageIndicator() {
    return List<Widget>.generate(_images.length, (int index) {
      return _buildIndicator(index == _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F53),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Lapor.in',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4A24C),
                    ),
                  ),
                )
              else if (_images.isEmpty)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'Tidak ada gambar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              else
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImage(_images[index]),
                          );
                        },
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    ),
                    if (_images.length > 1) ...[
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: _goToPrevious,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: _goToNext,
                        ),
                      ),
                    ],
                  ],
                ),
              if (!_isLoading && _images.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Selamat datang di Era Baru Pelayanan Publik!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '"Lapor.in keluhan dengan mudah, kapan saja dan dimana saja"',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text(
                  'Mulai',
                  style: TextStyle(color: Color(0xFF001F53)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
