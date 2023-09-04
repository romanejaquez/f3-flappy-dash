class FlappyDashTurn {

  final DateTime timeStamp;

  FlappyDashTurn({
    required this.timeStamp, 
  });

  factory FlappyDashTurn.fromFirebase(Map<String, dynamic> json) {
    return FlappyDashTurn(
      timeStamp: DateTime.parse(json['timestamp']),
    );
  }
}