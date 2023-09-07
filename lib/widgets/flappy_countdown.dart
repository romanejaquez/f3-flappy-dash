import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlappyDashCountdown extends StatefulWidget {
  const FlappyDashCountdown({super.key});

  @override
  State<FlappyDashCountdown> createState() => _FlappyDashCountdownState();
}

class _FlappyDashCountdownState extends State<FlappyDashCountdown> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutterdash.riv',
      artboard: 'countdown',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'countdown'
    )!;

    artboard.addController(smController);

    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return anim;
  }
}