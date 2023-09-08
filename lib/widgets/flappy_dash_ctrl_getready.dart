import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlappyDashGetReady extends StatefulWidget {
  const FlappyDashGetReady({super.key});

  @override
  State<FlappyDashGetReady> createState() => _FlappyDashGetReadyState();
}

class _FlappyDashGetReadyState extends State<FlappyDashGetReady> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutterdash.riv',
      artboard: 'getready',
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'getready'
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