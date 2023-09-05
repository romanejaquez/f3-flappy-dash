import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlutterGameDash extends StatefulWidget {
  const FlutterGameDash({super.key});

  @override
  State<FlutterGameDash> createState() => _FlutterGameDashState();
}

class _FlutterGameDashState extends State<FlutterGameDash> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutterdash.riv',
      artboard: 'flutterdashside',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'flutterdashside'
    )!;

    artboard.addController(smController);

    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 280,
      child: anim,
    );
  }
}