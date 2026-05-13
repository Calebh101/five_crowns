import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';

const rounds = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

class Scorecard {
  Map<User, Scores> scores;
  Scorecard(this.scores);

  factory Scorecard.fromUsers(List<User> users) {
    return Scorecard(Map.fromEntries(users.map((x) => MapEntry(x, Scores()))));
  }
}

class User {
  final String name;
  late Color themeColor;

  User(this.name, {Color? theme}) {
    themeColor = theme ?? Color((Random().nextDouble() * 0xFFFFFF).toInt());
  }
}

class Scores {
  Map<int, int> scores;
  Scores([Map<int, int>? scores_]) : scores = scores_ ?? {};

  int scoreAt(int round) {
    if (round < rounds.first || round > rounds.last) throw Exception("Invalid round: $round");
    return scores[round] ?? 0;
  }

  int get total => scores.values.nullIfEmpty?.reduce((a, b) => a + b) ?? 0;
}

Color? scoreToColor(int score) {
  if (score <= 0) {
    return Colors.green;
  } else if (score <= 20) {
    return Colors.yellow;
  } else {
    return Colors.deepOrangeAccent;
  }
}