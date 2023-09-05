import 'package:flappy_dash/utils.dart';
import 'package:flutter/material.dart';

class FlappyBgGradient extends StatelessWidget {
  const FlappyBgGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Utils.gradientTop,
            Utils.gradientBottom,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      ),
    );
  }
}