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
  late int id;

  static int thisId = 0;

  User(this.name, {Color? theme, int? id_}) {
    themeColor = theme ?? Color((Random().nextDouble() * 0xFFFFFF).toInt());
    id = id_ ?? nextId;
  }

  Widget toAvatar([double sizeFactor = 1]) => CircleAvatar(
    radius: 36 * sizeFactor,
    backgroundColor: themeColor.withAlpha((50 * sizeFactor).round()),
    child: Text(name.split("").first).fontSize(48 * sizeFactor),
  );

  int get nextId => thisId++;

  @override bool operator ==(Object other) => other is User && (identical(this, other) || id == other.id);
  @override int get hashCode => id ^ name.codeUnits.reduce((a, b) => a + b);
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
    return Colors.orange;
  } else {
    return Colors.deepOrangeAccent;
  }
}

Color placeToColor(int place) {
  if (place == 1) return Colors.green;
  if (place == 2) return Colors.orange;
  if (place == 3) return Colors.deepOrange;
  return Colors.red;
}