import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlappyJumpBtn extends StatefulWidget {

  final Function onPress;
  const FlappyJumpBtn({
    required this.onPress,
    super.key
  });

  @override
  State<FlappyJumpBtn> createState() => _FlappyJumpBtnState();
}

class _FlappyJumpBtnState extends State<FlappyJumpBtn> {

  late RiveAnimation anim;
  late StateMachineController ctrl;
  late SMITrigger inputTrigger;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flappydash_ctrl.riv',
      artboard: 'jumpbtn',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    ctrl = StateMachineController.fromArtboard(artboard, 'jumpbtn')!;
    artboard.addController(ctrl);
    inputTrigger = ctrl.findSMI('press')! as SMITrigger;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:(details) {
        inputTrigger.fire();
      },
      onTap: () {
        widget.onPress();
      },
      child: anim,
    );
  }
}