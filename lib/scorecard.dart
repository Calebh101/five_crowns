import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:five_crowns/main.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as p;

const rounds = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];

class Scorecard {
  Map<User, Scores> scores;
  Scorecard(this.scores);

  factory Scorecard.fromUsers(List<User> users) {
    return Scorecard(Map.fromEntries(users.map((x) => MapEntry(x, Scores()))));
  }

  Map<String, dynamic> toJson() {
    return {
      "scores": scores.map((k, v) => MapEntry(jsonEncode(k.toJson()), v.toJson())),
      "userId": User.thisId,
    };
  }

  static Scorecard fromJson(Map input) {
    User.thisId = input["userId"] ?? 0;
    return Scorecard((input["scores"] as Map?)?.map((k, v) => MapEntry(User.fromJson(jsonDecode(k)), Scores.fromJson(v))) ?? {});
  }

  static Scorecard? fromJsonSafe(String input) {
    try {
      final Map map = jsonDecode(input);
      return fromJson(map);
    } catch (_) {
      return null;
    }
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

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "theme": themeColor.toARGB32(),
      "id": id,
    };
  }

  static User fromJson(Map input) {
    return User(input["name"], theme: Color(input["theme"] ?? 0), id_: input["id"] ?? nextId);
  }

  Widget toAvatar([double sizeFactor = 1]) => CircleAvatar(
    radius: 36 * sizeFactor,
    backgroundColor: themeColor.withAlpha((50 * sizeFactor).round()),
    child: Text(name.split("").first).fontSize(48 * sizeFactor),
  );

  static int get nextId => thisId++;

  @override bool operator ==(Object other) => other is User && (identical(this, other) || id == other.id);
  @override int get hashCode => id ^ name.codeUnits.reduce((a, b) => a + b);
}

class Scores {
  Map<int, int> scores;
  Scores([Map<int, int>? scores_]) : scores = scores_ ?? {};

  Map<int, int> get scoresFilled {
    Map<int, int> newScores = Map.fromEntries(rounds.map((x) => MapEntry(x, 0)));

    for (final x in newScores.entries) {
      newScores[x.key] = scores[x.key] ?? 0;
    }

    return newScores;
  }

  Map<String, dynamic> toJson() {
    return {
      "scores": scores.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  static Scores fromJson(Map input) {
    return Scores((input["scores"] as Map?)?.map((k, v) => MapEntry(int.parse(k), v)));
  }

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

p.Document scoreboardToPdf(Scorecard scorecard) {
  final doc = p.Document();
  final winner = scorecard.scores.entries.sorted((a, b) => a.value.total.compareTo(b.value.total)).firstOrNull?.value.total ?? 0;

  doc.addPage(
    p.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => p.Container(
        width: double.infinity,
        height: double.infinity,
        child: p.Row(
          mainAxisAlignment: p.MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: p.CrossAxisAlignment.start,
          children: [
            p.Column(
              mainAxisAlignment: p.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: p.CrossAxisAlignment.center,
              children: [
                p.Text('Round'),
                ...rounds.map((round) => p.Text("$round\n")),
                p.Text('Total'),
              ],
            ),
            ...scorecard.scores.entries.map((entry) {
              final user = entry.key;
              final scores = entry.value;
              int totalSoFar = 0;

              return p.Expanded(
                child: p.Column(
                  mainAxisAlignment: p.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: p.CrossAxisAlignment.center,
                  children: [
                    p.Text(user.name, textAlign: p.TextAlign.center),
                    ...scores.scoresFilled.mapTo((round, score) {
                      totalSoFar += score;
                      return p.Text("$score${round == rounds.last ? "" : "\n= $totalSoFar"}", textAlign: p.TextAlign.center);
                    }),
                    p.Column(
                      children: [
                        p.Text(scores.total.toString(), style: p.TextStyle(fontSize: 24)),
                        if (scores.total == winner) p.Text("Winner"),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );

  return doc;
}