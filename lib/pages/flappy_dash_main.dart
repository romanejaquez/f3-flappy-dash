import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_dash/models/flappydashgamestatus.model.dart';
import 'package:flappy_dash/providers.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flappy_dash/widgets/flappy_bg_gradient.dart';
import 'package:flappy_dash/widgets/flappy_dash_bg.dart';
import 'package:flappy_dash/widgets/flutter_dash_white.dart';
import 'package:flappy_dash/widgets/flutter_game_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FlappyDashMain extends ConsumerStatefulWidget {

  const FlappyDashMain({super.key});

  @override
  ConsumerState<FlappyDashMain> createState() => FlappyDashMainState();
}

class FlappyDashMainState extends ConsumerState<FlappyDashMain> with TickerProviderStateMixin, WidgetsBindingObserver {

  AnimationController? ctrl;
  AnimationController? side2SideCtrl;
  final square1 = GlobalKey();
  final square2 = GlobalKey();
  bool wasReset = false;
  int yPos = 0;
  int itemHeight = 0;
  Timer difficultyTimer = Timer(Duration.zero, () {});
  Timer gameTimer = Timer(Duration.zero, () {});
  int secondsIncrement = 4000;
  int birdSpeedIncrement = 1000;
  int birdSpeedReverse = 500;
  bool gameElementsVisible = true;

  double? bottomPos = 0;
  double? topPos;
  String topImgPath = 'blue';
  String bottomImgPath = 'green';


  @override
  void initState() {
    super.initState();

    ctrl = AnimationController(vsync: this,
      duration: Duration(milliseconds: secondsIncrement),
    )..forward().whenComplete(() {
      randomizeYPos();
    });

    startGameTimer();

    startDifficultyTimer();

    side2SideCtrl = AnimationController(vsync: this,
      duration: Duration(milliseconds: birdSpeedIncrement),
    )..forward();

    ctrl!.addListener(onCheckForCollision);

    ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
      'status': FlappyDashGameStatus.inGame.name,
      'timestamp': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    ref.read(flappyDashProvider(() {
        triggerJump();
      }
    ));

    ref.read(flappyDashGameStatusProvider((FlappyDashGameStatusModel gameStatus) {
        
        if (gameStatus.status == FlappyDashGameStatus.tryAgain) {
          setState(() {
            restartGame();
          });
        }
        else if (gameStatus.status == FlappyDashGameStatus.backHome) {
          onBackHomeGo();
        }
      }
    ));
  }

  void startGameTimer() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      
      var dt = DateTime(2023,0,0,0,0,0,timer.tick);

      ref.read(gameTimerProvider.notifier).state = 
        '${DateFormat('mm').format(dt)}:${DateFormat('ss').format(dt)}:${(dt.millisecond).toStringAsFixed(0)}';
    });
  }

  void randomizeYPos() {
    setState(() {
      final rand = Random();

      final pos = rand.nextInt(2);
      bottomPos = pos == 0 ? 0 : null;
      topPos = pos == 1 ? 0 : null;

      final imgRand = rand.nextInt(2);
      topImgPath = imgRand == 0 ? 'blue' : 'pink';
      bottomImgPath = imgRand == 1 ? 'green' : 'purple';
    });
  }

  void startDifficultyTimer() {
    difficultyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {

      if (secondsIncrement == 1000) {
        timer.cancel();
        return;
      }

      secondsIncrement = secondsIncrement - 100;

      if (ctrl != null) {
        ctrl!.duration = Duration(milliseconds: secondsIncrement);
      }

      birdSpeedIncrement = birdSpeedIncrement - 10;

      if (side2SideCtrl != null) {
        side2SideCtrl!.duration = Duration(milliseconds: birdSpeedIncrement);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration.zero, () {
      ref.read(flappyStateProvider.notifier).state = FlappyStates.game;
    });

    //itemHeight = (MediaQuery.sizeOf(context).height / 100).round() - 3;
    randomizeYPos();

    return WillPopScope(
      onWillPop:() {

        ref.read(livesStateProvider.notifier).state = 3;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            const FlappyBgGradient(),

            Align(
              alignment: Alignment.topCenter,
              child: FlappyDashBg(
                bgState: FlappyBg.clouds,
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.5,
                child: FlappyDashBg(
                  bgState: FlappyBg.flowers,
                ),
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: Consumer(builder: (context, ref, child) {
                  return Padding(
                    padding: const EdgeInsets.all(50),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 150, height: 150,
                          child: FlutterDashWhite()),
                        Text(ref.watch(livesStateProvider).toString(),
                          style: TextStyle(fontSize: 140, color: Colors.white),
                        ),
                      ],
                    ),
                  );
              },),
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Consumer(builder: (context, ref, child) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.all(30),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timelapse_outlined, color: Colors.white, size: 50),
                        SizedBox(width: 10),
                        Text(ref.watch(gameTimerProvider).toString(),
                          style: TextStyle(fontSize: 50, color: Colors.white),
                        ),
                      ],
                    ),
                  );
              },),
            ),
            
            Positioned(
              bottom: bottomPos,
              top: topPos,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset((MediaQuery.sizeOf(context).width / 200) + 1,
                    0),
                  end: const Offset(-1, 0)
                  ,
                ).animate(CurvedAnimation(parent: ctrl!, curve: Curves.linear)),
                child: SizedBox(
                  key: square1,
                  width: 200, 
                  height: (MediaQuery.sizeOf(context).height / 2) - 100,
                  child: SvgPicture.asset(
                    bottomPos == 0 ? './assets/imgs/${bottomImgPath}_tube.svg' : './assets/imgs/${topImgPath}_tube.svg',
                    fit: BoxFit.fill,
                  )
                ),
              ),
            ),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Visibility(
                visible: gameElementsVisible,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: const Offset(0, 1),
                  ).animate(CurvedAnimation(parent: side2SideCtrl!, curve: Curves.easeInOut)),
                  child: Container(
                    margin: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.25),
                    width: 250,
                    height: 280,
                    child: Stack(
                      children: [
                        const FlutterGameDash(),
                        Center(
                          child: Container(
                            key: square2,
                            width: 180,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(150)
                            ),
                          ),
                        )
                      ],
                    )
                  )
                  .animate(
                    onComplete: (ctrl) {
                      ctrl.repeat(reverse: true);
                    }
                  )
                  .slideY(
                    begin: 0, end: 0.25,
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
            
            GestureDetector(
              onTap: () {
                triggerJump();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),

            Positioned.fill(
              child: Visibility(
                visible: !gameElementsVisible,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFDF7D),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      padding: EdgeInsets.all(100),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.thumb_up, color: Color(0xFFB1540F), size: 100)
                              .animate(
                                onComplete: (controller) {
                                  controller.repeat(reverse: true);
                                },
                              ).rotate(
                                begin: 0.0125, end: 0.08,
                                duration: 1.seconds,
                                curve: Curves.easeInOut,
                              ),
                              SizedBox(width: 20),
                              Text('Nicely Done!', style: TextStyle(fontSize: 90, color: Color(0xFFB1540F))),
                            ],
                          ),
                          Text('You lasted', style: TextStyle(fontSize: 60, color: Color(0xFFBA7B33))),
                          Text(ref.read(gameTimerProvider), style: TextStyle(fontSize: 100, color: Colors.black)),
                          SizedBox(height: 40),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFB1540F),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.all(30)
                                ),
                                onPressed: () {
                                  restartGame();
                                }, 
                                child: Text('Try Again', style: TextStyle(fontSize: 50, color: Colors.white)),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFB1540F).withOpacity(0.25),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.all(30)
                                ),
                                onPressed: () {
                                  onBackHomeGo();
                                }, 
                                child: Text('Back Home', style: TextStyle(fontSize: 40, color: Colors.black)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ).animate(
                      onComplete:(controller) {
                        controller.repeat(reverse: true);
                      },
                    )
                    .scaleXY(
                      begin: 1, end: 1.05,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ).animate()
                .fadeIn(
                  duration: 0.25.seconds,
                  curve: Curves.easeInOut,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void triggerJump() {
    if (side2SideCtrl != null) {
      side2SideCtrl!.reverseDuration = Duration(milliseconds: birdSpeedReverse);
      side2SideCtrl!.reverse().then((value) {
        side2SideCtrl!.forward();
      });
    }
  }

  void onBackHomeGo() {
    ref.read(livesStateProvider.notifier).state = 3;
    GoRouter.of(context).go('/');
  }

  void onCheckForCollision() {

    if (ctrl != null && ctrl!.value == 1) {
      resetThings();
      startThings();
      return;
    }

    if (square1.currentContext == null && square2.currentContext == null) {
      return;
    }

    RenderBox? box1 = square1.currentContext!.findRenderObject() as RenderBox;
    RenderBox? box2 = square2.currentContext!.findRenderObject() as RenderBox;

    if (box1 == null || box2 == null){
      return;
    }

    final size1 = box1.size;
    final size2 = box2.size;

    final position1 = box1.localToGlobal(Offset.zero);
    final position2 = box2.localToGlobal(Offset.zero);

    final collide = (position1.dx < position2.dx + size2.width &&
        position1.dx + size1.width > position2.dx &&
        position1.dy < position2.dy + size2.height &&
        position1.dy + size1.height > position2.dy);

    if (collide) {
      ref.read(livesStateProvider.notifier).state = ref.read(livesStateProvider) - 1;
      resetThings();
    }
  }

  void restartGame() {
    
    ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
      'status': FlappyDashGameStatus.inGame.name,
      'timestamp': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    ref.read(livesStateProvider.notifier).state = 3;

    setState(() {
      gameElementsVisible = true;
      secondsIncrement = 4000;
      birdSpeedIncrement = 1000;  
    });

    ctrl!.duration = Duration(milliseconds: secondsIncrement);
    side2SideCtrl!.duration = Duration(milliseconds: birdSpeedIncrement);

    side2SideCtrl!.forward();
    
    startGameTimer();
    startDifficultyTimer();
    startThings();
  }

  void resetThings() {

    if (ref.read(livesStateProvider) <= 0) {

      ctrl!.removeListener(onCheckForCollision);
      ctrl!.reset();
      wasReset = true;
      side2SideCtrl!.reset();
      ref.read(flappyStateProvider.notifier).state = FlappyStates.restart;
      gameTimer.cancel();
      difficultyTimer.cancel();

      ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status').set({
          'status': FlappyDashGameStatus.endGame.name,
          'timestamp': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

      setState(() {
        gameElementsVisible = false;
      });
    }
    else {
      ctrl!.removeListener(onCheckForCollision);
      ctrl!.reset();
      wasReset = true;
      randomizeYPos();
      startThings();
    }
  }

  void startThings() {

    if (wasReset) {
      ctrl!.addListener(onCheckForCollision);
      wasReset = false;
    }
    
    ctrl!.forward();
  }

  @override
  void dispose() {
    ctrl!.dispose();
    side2SideCtrl!.dispose();
    gameTimer.cancel();
    difficultyTimer.cancel();

    super.dispose();
  }
}