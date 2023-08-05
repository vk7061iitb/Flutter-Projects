import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SvgAnimation extends HookWidget {
  const SvgAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(seconds: 2), // Adjust the duration as needed
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.repeat(reverse: true);

    return Center(
      child: ScaleTransition(
        scale: animation,
        child: SvgPicture.asset(
          "assets/images/tax-animate.svg", // Replace with your SVG asset path
        ),
      ),
    );
  }
}
