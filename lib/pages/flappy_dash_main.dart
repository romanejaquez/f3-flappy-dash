import 'dart:async';
import 'dart:math';

import 'package:flappy_dash/providers.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flappy_dash/widgets/flappy_bg_gradient.dart';
import 'package:flappy_dash/widgets/flappy_dash_bg.dart';
import 'package:flappy_dash/widgets/flutter_game_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

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
  int secondsIncrement = 4000;


  double? bottomPos = 0;
  double? topPos;

  @override
  void initState() {
    super.initState();

    ctrl = AnimationController(vsync: this,
      duration: Duration(milliseconds: secondsIncrement),
    )..forward().whenComplete(() {
      randomizeYPos();
    });

    difficultyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {

      if (secondsIncrement == 1000) {
        timer.cancel();
        return;
      }

      secondsIncrement = secondsIncrement - 100;

      if (ctrl != null) {
        ctrl!.duration = Duration(milliseconds: secondsIncrement);
      }
    });

    side2SideCtrl = AnimationController(vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    ctrl!.addListener(onCheckForCollision);

    ref.read(flappyDashProvider(() {
        final state = ref.read(flappyStateProvider);
        if (state == FlappyStates.game) {
          triggerJump();
        }
        else if (state == FlappyStates.restart) {
          ref.read(livesStateProvider.notifier).state = 3;
          GoRouter.of(context).go('/');
        }
      }
    ));
  }

  void randomizeYPos() {
    setState(() {
      final rand = Random();
      //yPos = rand.nextInt(itemHeight) + 1;

      final pos = rand.nextInt(2);
      bottomPos = pos == 0 ? 0 : null;
      topPos = pos == 1 ? 0 : null;
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
        ref.read(flappyStateProvider.notifier).state = FlappyStates.init;
        return Future.value(true);
      },
      child: Scaffold(
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
              alignment: Alignment.topLeft,
              child: Consumer(builder: (context, ref, child) {
                  return Text(ref.watch(livesStateProvider).toString(),
                    style: TextStyle(fontSize: 50),
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
                    bottomPos == 0 ? './assets/imgs/green_tube.svg' : './assets/imgs/blue_tube.svg',
                    fit: BoxFit.fill,
                  )
                ),
              ),
            ),
            
            Align(
              alignment: Alignment.centerLeft,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, -1),
                  end: Offset(0, 1),
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
                // .animate(
                //   onComplete: (ctrl) {
                //     ctrl.repeat(reverse: true);
                //   }
                // )
                // .slideY(
                //   begin: 0, end: 0.25,
                //   duration: 1.seconds,
                //   curve: Curves.easeInOut,
                // ),
              ),
            )
          
            ,
            
            GestureDetector(
              onTap: () {
                triggerJump();
              },
              child: Container(
                color: Colors.transparent,
              ),
            )
          ],
        ),
      ),
    );
  }

  void triggerJump() {
    if (side2SideCtrl != null) {
      side2SideCtrl!.reverseDuration = const Duration(milliseconds: 500);
      side2SideCtrl!.reverse().then((value) {
        side2SideCtrl!.forward();
      });
    }
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

  void resetThings() {

    if (ref.read(livesStateProvider) == 0) {
      ctrl!.removeListener(onCheckForCollision);
      ctrl!.reset();
      wasReset = true;
      ref.read(flappyStateProvider.notifier).state = FlappyStates.restart;
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
}