import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flappy_dash/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:core';

import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {

  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> with TickerProviderStateMixin, WidgetsBindingObserver {

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
      triggerJump();
    })); 
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

    //itemHeight = (MediaQuery.sizeOf(context).height / 100).round() - 3;
    randomizeYPos();

    return Scaffold(
      body: Stack(
        children: [
          // Positioned(
          //   child: SlideTransition(
          //     position: Tween<Offset>(
          //       begin: Offset(-1, 1 / (MediaQuery.sizeOf(context).height / 100) + yPos),
          //       end: Offset((MediaQuery.sizeOf(context).width / 100) + 1,
          //         1 / (MediaQuery.sizeOf(context).height / 100) + yPos)
          //       ,
          //     ).animate(CurvedAnimation(parent: ctrl!, curve: Curves.linear)),
          //     child: Container(
          //       key: square1,
          //       width: 100, height: 100,
          //       decoration: const BoxDecoration(
          //         color: Colors.blue,
          //         shape: BoxShape.circle,
          //       ),
          //     ),
          //   ),
          // ),

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
                begin: Offset(-1, 0),
                end: Offset((MediaQuery.sizeOf(context).width / 100) + 1,
                  0)
                ,
              ).animate(CurvedAnimation(parent: ctrl!, curve: Curves.linear)),
              child: Container(
                key: square1,
                width: 100, height: (MediaQuery.sizeOf(context).height / 2) - 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Center(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -2),
                end: Offset(0, 2),
              ).animate(CurvedAnimation(parent: side2SideCtrl!, curve: Curves.easeInOut)),
              child: Container(
                key: square2,
                width: 100, height: 100,
                decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              ),
            ),
          )
        ],
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