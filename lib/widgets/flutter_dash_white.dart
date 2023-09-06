import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlutterDashWhite extends StatefulWidget {

  double? birdWidth;
  double? birdHeight;
  
  FlutterDashWhite({
    this.birdHeight,
    this.birdWidth,
    super.key});

  @override
  State<FlutterDashWhite> createState() => _FlutterDashWhiteState();
}

class _FlutterDashWhiteState extends State<FlutterDashWhite> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutter_dash_white.riv',
      artboard: 'flutter_dash',
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'flutter_dash'
    )!;

    artboard.addController(smController);

    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.birdWidth,
      height: widget.birdHeight,
      child: anim,
    );
  }
}