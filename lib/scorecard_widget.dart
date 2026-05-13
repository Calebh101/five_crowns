import 'package:collection/collection.dart';
import 'package:five_crowns/scorecard.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/functions.dart';

class ScorecardWidget extends StatefulWidget {
  final Scorecard scorecard;
  const ScorecardWidget({super.key, required this.scorecard});

  @override
  State<ScorecardWidget> createState() => _ScorecardWidgetState();
}

class _ScorecardWidgetState extends State<ScorecardWidget> {
  int? currentRound = rounds.first;

  @override
  Widget build(BuildContext context) {
    final scores = widget.scorecard.scores.entries.where((x) => x.key.name.isNotEmpty);
    final allTotals = scores.map((x) => x.value.total).sorted((a, b) => b.compareTo(a));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [if (scores.isNotEmpty) TableRow(
            children: [
              SizedBox.shrink(),
              ...[...rounds, null].map((round) {
                return InkWell(
                  onTap: () {
                    currentRound = round;
                    setState(() {});
                  },
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: round == null ? Icon(Icons.flag, color: currentRound == null ? Colors.green : Colors.blue) : Text(round.toString()).color(currentRound == round ? Colors.blue : null),
                    ),
                  ),
                );
              }),
            ]
          ), ...scores.map((entry) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: entry.key.themeColor.withAlpha(50),
                        child: Text(entry.key.name.split("").first).fontSize(48),
                      ),
                      SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.name).fontSize(16),
                          Builder(
                            builder: (context) {
                              final value = entry.value.total;
                              final winner = value == allTotals.first;
                              return Text(value.toString()).fontSize(24).color(winner ? Colors.green : (currentRound == null ? Colors.red : null));
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ...rounds.map((r) {
                  final value = entry.value.scores[r] ?? 0;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 50,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text(value.toString()).fontSize(20).color((currentRound ?? rounds.max + 1) <= r ? null : scoreToColor(value))),
                    ),
                  );
                }),
                SizedBox(
                  width: 50,
                ),
              ],
            );
          })],
        ),
      ),
    );
  }
}