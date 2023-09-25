import 'package:flappy_dash/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class FlappyDashQRCode extends ConsumerStatefulWidget {
  const FlappyDashQRCode({super.key});

  @override
  ConsumerState<FlappyDashQRCode> createState() => _FlappyDashQRCodeState();
}

class _FlappyDashQRCodeState extends ConsumerState<FlappyDashQRCode> {

  late RiveAnimation anim;
  late StateMachineController smController;
  bool isInitialized = false;
  
  SMITrigger? showQRCodeTrigger;
  SMITrigger? hideQRCodeTrigger;

  @override
  void initState() {
    super.initState();

    anim = RiveAnimation.asset(
      'assets/anims/roulette.riv',
      artboard: 'qrcodepanelroulette',
      onInit: onRiveInit,
      fit: BoxFit.contain,
    );
  }

  void onRiveInit(Artboard artboard) {

    smController = StateMachineController.fromArtboard(
      artboard,
      'qrcodepanelroulette'
    )!;

    artboard.addController(smController);
    smController = StateMachineController.fromArtboard(
      artboard, 'qrcodepanelroulette')!;

    artboard.addController(smController);
    showQRCodeTrigger = smController.findSMI('qrcodein') as SMITrigger;
    hideQRCodeTrigger = smController.findSMI('qrcodeout') as SMITrigger;
    
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInitialized) {
      Future.delayed(1.seconds, () {
        showQRCodeTrigger!.fire();
      });
    }

    return anim;
  }
}