class FlappyDashGameStatusModel {

  final FlappyDashGameStatus status;
  final DateTime timeStamp;

  FlappyDashGameStatusModel({
    required this.status,
    required this.timeStamp,
  });

  factory FlappyDashGameStatusModel.fromFirebase(Map<String, dynamic> json) {
    return FlappyDashGameStatusModel(
      status: FlappyDashGameStatus.values.firstWhere((element) => element.name == json['status']),
      timeStamp: DateTime.parse(json['timestamp']),
    );
  }
}

enum FlappyDashGameStatus {
  inGame,
  startScreen,
  leaderboards,
  endGame,
  tryAgain,
  backHome,
}