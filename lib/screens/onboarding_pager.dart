import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/dot_indicator.dart';
import 'onboarding_slide_one.dart';
import 'onboarding_slide_two.dart';

class OnboardingPager extends StatefulWidget {
  const OnboardingPager({super.key});

  @override
  State<OnboardingPager> createState() => _OnboardingPagerState();
}

class _OnboardingPagerState extends State<OnboardingPager> {
  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();
  int currentPage = 0;

  void _nextPage() {
    if (currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.space) {
              _nextPage();
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _previousPage();
            }
          }
        },
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              children: const [
                OnboardingSlideOne(),
                OnboardingSlideTwo(),
              ],
            ),

            // 🔹 DOT INDICATOR
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: DotIndicator(currentPage: currentPage),
            ),
          ],
        ),
      ),
    );
  }
}

