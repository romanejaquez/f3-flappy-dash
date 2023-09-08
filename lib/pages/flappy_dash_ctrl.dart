import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_dash/models/flappydashgamestatus.model.dart';
import 'package:flappy_dash/providers.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flappy_dash/widgets/flappy_bg_gradient.dart';
import 'package:flappy_dash/widgets/flappy_dash_basic_btn.dart';
import 'package:flappy_dash/widgets/flappy_dash_ctrl_getready.dart';
import 'package:flappy_dash/widgets/flappy_jump_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlappyDashCtrl extends ConsumerStatefulWidget {
  const FlappyDashCtrl({super.key});

  @override
  ConsumerState<FlappyDashCtrl> createState() => _FlappyDashCtrlState();
}

class _FlappyDashCtrlState extends ConsumerState<FlappyDashCtrl> {

  bool isGameButtonEnabled = false;
  FlappyDashGameStatus gameStatusValue = FlappyDashGameStatus.inGame;

  @override
  void initState() {
    super.initState();

    ref.read(flappyDashGameStatusProvider((FlappyDashGameStatusModel gameStatus) {
        setState(() {
          gameStatusValue = gameStatus.status;
          isGameButtonEnabled = gameStatus.status == FlappyDashGameStatus.inGame;
        });
      }
    ));
  }

  @override
  Widget build(BuildContext context) {

    Widget currentDisplayingWidget = const SizedBox.shrink();

    switch(gameStatusValue) {
      case FlappyDashGameStatus.backHome:
        currentDisplayingWidget = 
        FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.5,
          child: FlappyDashBasicBtn(
            btnOption: ButtonOptions.start,
            onPress: () {
              ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
                'status': FlappyDashGameStatus.startGame.name,
                'timestamp': DateTime.now().toIso8601String(),
              }, SetOptions(merge: true));
            }
          ),
        );
        break;
      case FlappyDashGameStatus.endGame:
        currentDisplayingWidget = Padding(
          padding: const EdgeInsets.all(80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FlappyDashBasicBtn(
                  btnOption: ButtonOptions.again,
                  onPress: () {
                    ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
                      'status': FlappyDashGameStatus.tryAgain.name,
                      'timestamp': DateTime.now().toIso8601String(),
                    }, SetOptions(merge: true));
                  }
                ),
              ),
              Expanded(
                child: FlappyDashBasicBtn(
                  btnOption: ButtonOptions.home,
                  onPress: () {
                    ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
                      'status': FlappyDashGameStatus.backHome.name,
                      'timestamp': DateTime.now().toIso8601String(),
                    }, SetOptions(merge: true));
                  }
                ),
              ),
            ],
          ),
        );
        break;
      case FlappyDashGameStatus.inGame:
        currentDisplayingWidget = FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: FlappyJumpBtn(onPress: () {
            ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-turns').set({
              'timestamp': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          }),
        );
        break;
      case FlappyDashGameStatus.startGame:
        currentDisplayingWidget = FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: FlappyDashGetReady()
        );
        break;
      default:
        currentDisplayingWidget = SizedBox();
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          const FlappyBgGradient(),
          Center(
            child: currentDisplayingWidget,
          ),
        ],
      ),
    );
  }
}