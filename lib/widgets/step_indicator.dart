import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              final isCurrent = index == currentStep - 1;

              return Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent
                          ? const Color(0xFFD4A24C)
                          : isActive
                          ? const Color(0xFF001F53)
                          : Colors.grey[300],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent || isActive ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Container(
                      width: 50,
                      height: 2,
                      color: isActive ? const Color(0xFF001F53) : Colors.grey[300],
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lokasi & Deskripsi',
                style: TextStyle(
                  color: currentStep == 1 ? const Color(0xFF001F53) : Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                'Kategori',
                style: TextStyle(
                  color: currentStep == 2 ? const Color(0xFF001F53) : Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                'Verifikasi',
                style: TextStyle(
                  color: currentStep == 3 ? const Color(0xFF001F53) : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
