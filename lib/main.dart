import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flappy_dash/pages/flappy_dash_main.dart';
import 'package:flappy_dash/pages/launch_page.dart';
import 'package:flappy_dash/providers.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:core';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: FlappyDashApp()));
}

class FlappyDashApp extends ConsumerStatefulWidget {
  const FlappyDashApp({super.key});

  @override
  ConsumerState<FlappyDashApp> createState() => _FlappyDashAppState();
}

class _FlappyDashAppState extends ConsumerState<FlappyDashApp> {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Mabook',
      ),
      routeInformationProvider: AppRoutes.router.routeInformationProvider,
      routeInformationParser: AppRoutes.router.routeInformationParser,
      routerDelegate: AppRoutes.router.routerDelegate,
    );
  }
}

class AppRoutes {
  
  static final router = GoRouter(
    routerNeglect: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
            return const LaunchPage();
        },
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) {
            return const FlappyDashMain();
        },
      ),
    ]
  );
}

