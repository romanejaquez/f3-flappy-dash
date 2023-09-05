import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlutterDashWave extends StatefulWidget {
  const FlutterDashWave({super.key});

  @override
  State<FlutterDashWave> createState() => _FlutterDashWaveState();
}

class _FlutterDashWaveState extends State<FlutterDashWave> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutterdash.riv',
      artboard: 'flutterdashwave',
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'flutterdashwave'
    )!;

    artboard.addController(smController);

    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: anim,
    );
  }
}