import 'package:flappy_dash/utils.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FlappyDashBasicBtn extends StatefulWidget {
  
  final ButtonOptions btnOption;
  final Function onPress;
  const FlappyDashBasicBtn({
    required this.btnOption,
    required this.onPress,
    super.key
  });

  @override
  State<FlappyDashBasicBtn> createState() => _FlappyDashBasicBtnState();
}

class _FlappyDashBasicBtnState extends State<FlappyDashBasicBtn> {

  late RiveAnimation anim;
  late StateMachineController ctrl;
  late SMITrigger inputTrigger;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flappydash_ctrl.riv',
      artboard: '${widget.btnOption.name}btn',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {
    ctrl = StateMachineController.fromArtboard(artboard, '${widget.btnOption.name}btn',)!;
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