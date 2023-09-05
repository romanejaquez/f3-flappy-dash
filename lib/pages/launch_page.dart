import 'package:flappy_dash/pages/flappy_dash_main.dart';
import 'package:flappy_dash/providers.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flappy_dash/widgets/flappy_bg_gradient.dart';
import 'package:flappy_dash/widgets/flutter_dash_wave.dart';
import 'package:flappy_dash/widgets/flutter_dash_white.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LaunchPage extends ConsumerStatefulWidget {
  const LaunchPage({super.key});

  @override
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // ref.watch(flappyDashProvider(() {
    //   final state = ref.read(flappyStateProvider);
    //   if (state == FlappyStates.init) {
    //     ref.read(flappyStateProvider.notifier).state = FlappyStates.game;
    //     GoRouter.of(context).go('/game');
    //   }
    // }));

    return Scaffold(
      body: Stack(
        children: [
          const FlappyBgGradient(),

          Positioned(
            child: SizedBox(
              width: 200, height: 200,
              child: SvgPicture.asset('./assets/imgs/cloud.svg',
              fit: BoxFit.contain
            ),
            ).animate(
              onComplete: (controller) {
                controller.repeat();
              }
            )
            .slide(
              begin: Offset(-1, 1 / (MediaQuery.sizeOf(context).height / 200)),
                end: Offset((MediaQuery.sizeOf(context).width / 200),
                  1 / (MediaQuery.sizeOf(context).height / 200)),
              duration: 20.seconds,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset('./assets/imgs/top_clouds.svg',
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height / 2,
              fit: BoxFit.contain
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset('./assets/imgs/mountain.svg',
              width: MediaQuery.sizeOf(context).width,
              fit: BoxFit.cover
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: SvgPicture.asset('./assets/imgs/flowers.svg',
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height / 2,
              fit: BoxFit.cover
            ),
          ),

          Positioned(
            bottom: 0,
            left: -50,
            child: Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: SvgPicture.asset('./assets/imgs/firebase_flutter_badge.svg',
                fit: BoxFit.cover
              ).animate(
                onComplete: (ctrl) {
                  ctrl.repeat(reverse: true);
                }
              )
              .scaleXY(
                begin: 1, end: 1.125,
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: (MediaQuery.sizeOf(context).width / 2) * -1,
            bottom: (MediaQuery.sizeOf(context).height / 2) * -1,
            child: Align(
              child: Container(
                margin: const EdgeInsets.only(top: 100, right: 200),
                child: FlutterDashWave()),
            ),
          ),

          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 200, bottom: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 700,
                    height: 400,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset('./assets/imgs/Flappy Dash.svg',
                        ).animate(
                          onComplete: (ctrl) {
                            ctrl.repeat(reverse: true);
                          }
                        )
                        .scaleXY(
                          begin: 1, end: 1.05,
                          duration: 4.seconds,
                          curve: Curves.easeInOut,
                        ),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Opacity(
                            opacity: 0.5,
                            child: FlutterDashWhite())
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go('/game');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 50, top: 20),
                      child: SvgPicture.asset(
                        './assets/imgs/startbtn.svg',
                      ),
                    ).animate(
                      onComplete: (ctrl) {
                        ctrl.repeat(reverse: true);
                      }
                    )
                    .scaleXY(
                      begin: 1, end: 1.125,
                      duration: 1.seconds,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          
        ],
      ),
    );
  }
}