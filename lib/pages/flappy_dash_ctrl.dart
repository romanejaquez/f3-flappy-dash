import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_dash/models/flappydashgamestatus.model.dart';
import 'package:flappy_dash/providers.dart';
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
      case FlappyDashGameStatus.startScreen:
        currentDisplayingWidget = TextButton(
          onPressed: () {
            ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
              'status': FlappyDashGameStatus.inGame.name,
              'timestamp': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          },
          child: Text('START GAME!!')
        );
        break;

      case FlappyDashGameStatus.endGame:
        currentDisplayingWidget = Column(
          children: [
            TextButton(
              onPressed: () {
                ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
                  'status': FlappyDashGameStatus.tryAgain.name,
                  'timestamp': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));
              },
              child: Text('Try Again')
            ),
            TextButton(
              onPressed: () {
                ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
                  'status': FlappyDashGameStatus.backHome.name,
                  'timestamp': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));
              },
              child: Text('Back Home')
            )
          ],
        );
        break;
      case FlappyDashGameStatus.inGame:
        currentDisplayingWidget = GestureDetector(
          onTap: isGameButtonEnabled ? () {
            ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-turns').set({
              'timestamp': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          } : null,
          child: Opacity(
            opacity: isGameButtonEnabled ? 1 : 0.5,
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text('Press!!!'),
            ),
          ),
        );
        break;
      default: 
    }

    return Scaffold(
      body: Center(
        child: currentDisplayingWidget,
      ),
    );
  }
}