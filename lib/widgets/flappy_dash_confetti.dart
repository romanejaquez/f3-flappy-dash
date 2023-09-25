import 'package:flappy_dash/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class FlappyDashConfetti extends ConsumerStatefulWidget {
  const FlappyDashConfetti({super.key});

  @override
  ConsumerState<FlappyDashConfetti> createState() => _FlappyDashConfettiState();
}

class _FlappyDashConfettiState extends ConsumerState<FlappyDashConfetti> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;
  late SMITrigger confettiTrigger;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      './assets/anims/flutterdash.riv',
      artboard: 'dashconfetti',
      fit: BoxFit.contain,
      onInit: onRiveInit,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'dashconfetti'
    )!;

    artboard.addController(smController);
    confettiTrigger = smController.findSMI('dashconfetti') as SMITrigger;
    
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    var qrCodeThresholdExceeded = ref.watch(qrcodeThresholdProvider);

    if (isInitialized && qrCodeThresholdExceeded) {
      confettiTrigger.fire();
    }

    return anim;
  }
}