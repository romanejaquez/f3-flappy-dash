import 'package:flappy_dash/utils.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlappyDashBg extends StatefulWidget {

  final FlappyBg bgState;
  
  const FlappyDashBg({
    required this.bgState,
    super.key});

  @override
  State<FlappyDashBg> createState() => _FlappyDashBgState();
}

class _FlappyDashBgState extends State<FlappyDashBg> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flappydashbg.riv',
      artboard: widget.bgState.name,
      fit: BoxFit.cover,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      widget.bgState.name,
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
      height: MediaQuery.sizeOf(context).height / 2,
      child: anim,
    );
  }
}