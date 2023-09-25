import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_dash/models/flappydashgamestatus.model.dart';
import 'package:flappy_dash/models/flappydashturn.dart';
import 'package:flappy_dash/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final flappyDashProvider = StreamProvider.family<FlappyDashTurn, VoidCallback>((ref, callback) async* {

  final rouletteEvents = ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-turns')
    .snapshots().map((event) => FlappyDashTurn.fromFirebase((event.data() as Map<String, dynamic>)));

  await for (var event in rouletteEvents) {
    callback();
  }
});

final flappyDashGameStatusProvider = StreamProvider.family<FlappyDashTurn, Function>((ref, callback) async* {

  final rouletteEvents = ref.read(dbProvider).collection('flappy-dash-events').doc('flappy-dash-game-status')
    .snapshots().map((event) => FlappyDashGameStatusModel.fromFirebase((event.data() as Map<String, dynamic>)));

  await for (var event in rouletteEvents) {
    callback(event);
  }
});

final livesStateProvider = StateProvider<int>((ref) {
  return 3;
});

final gameTimerProvider = StateProvider<String>((ref) {
  return "00:00";
});

final qrcodeThresholdProvider = StateProvider.autoDispose<bool>((ref) => false);
