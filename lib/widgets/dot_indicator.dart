import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final int currentPage;

  const DotIndicator({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(isActive: currentPage == 0),
        const SizedBox(width: 8),
        _dot(isActive: currentPage == 1),
      ],
    );
  }

  Widget _dot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 10 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
