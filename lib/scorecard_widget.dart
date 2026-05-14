import 'package:collection/collection.dart';
import 'package:five_crowns/main.dart';
import 'package:five_crowns/scorecard.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:printing/printing.dart';
import 'package:styled_logger/styled_logger.dart';

class ScorecardWidget extends StatefulWidget {
  final Scorecard scorecard;
  final VoidCallback? onModify;

  const ScorecardWidget({super.key, required this.scorecard, this.onModify});

  @override
  State<ScorecardWidget> createState() => _ScorecardWidgetState();
}

class _ScorecardWidgetState extends State<ScorecardWidget> {
  int? currentRound = rounds.first;

  void onModify() {
    widget.onModify?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scores = widget.scorecard.scores.entries.where((x) => x.key.name.isNotEmpty);
    final allTotals = scores.map((x) => x.value.total).sorted((a, b) => a.compareTo(b));

    int place(int total) {
      return allTotals.toList().indexWhere((x) => x == total) + 1;
    }

    return scores.isEmpty ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No scorecard loaded!").fontSize(24),
          Text.rich(TextSpan(
            children: [
              TextSpan(text: "Press "),
              WidgetSpan(child: Icon(Icons.note_add)),
              TextSpan(text: " to create a new scorecard!"),
            ],
          )),
        ],
      ),
    ) : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
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
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () async {
                                final result = await ConfirmationDialogue.show(context: context, title: "Are you sure?", description: "Are you sure you want to delete player ${entry.key.name}? You can't undo this!");
                                if (result != true) return;
                                widget.scorecard.scores.remove(entry.key);
                                onModify();
                                setState(() {});
                              }, icon: Icon(Icons.delete, color: Colors.red)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: entry.key.toAvatar(),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key.name).fontSize(16),
                            Builder(
                              builder: (context) {
                                final value = entry.value.total;
                                final winner = value == allTotals.first;
                                return Text(value.toString()).fontSize(24).color(winner ? Colors.green : (currentRound == null ? placeToColor(place(entry.value.total)) : null));
                              }
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ...rounds.map((r) {
                    final value = entry.value.scores[r] ?? 0;

                    return InkWell(
                      onTap: () {},
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 50,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text(value.toString()).fontSize(20).color((currentRound ?? rounds.max + 1) <= r ? null : scoreToColor(value))),
                        ),
                      ),
                    );
                  }),
                  SizedBox(
                    width: 50,
                  ),
                ],
              );
            }),
            TableRow(
              children: [
                IconButton(onPressed: () async {
                  final controller = TextEditingController();

                  final result = await showDialog<bool>(context: context, builder: (context) {
                    return AlertDialog(
                      title: Text("Add Player"),
                      content: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: "Name",
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => context.navigator.pop(false), child: Text("Cancel")),
                        TextButton(onPressed: () => context.navigator.pop(true), child: Text("OK")),
                      ],
                    );
                  });

                  if (result != true || controller.text.trim().isEmpty) return;
                  final user = User(controller.text);
                  widget.scorecard.scores[user] = Scores();
                  onModify();
                  setState(() {});
                }, icon: Icon(Icons.add)),
                ...[...rounds, null].map((round) {
                  if (round == null || round != currentRound) return SizedBox.shrink();

                  return IconButton(onPressed: () async {
                    final result = await showDialog<Map<User, int>>(context: context, builder: (context) => RoundInputDialogue(round: round, scores: Map.fromEntries(scores)));
                    Logger.print("Found result of ${result.runtimeType} and ${result?.length} entries");
                    if (result == null) return;

                    for (final x in result.entries) {
                      widget.scorecard.scores[x.key]!.scores[round] = x.value;
                      onModify();
                    }

                    setState(() {});
                  }, icon: Icon(Icons.edit));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RoundInputDialogue extends StatefulWidget {
  final int round;
  final Map<User, Scores> scores;

  const RoundInputDialogue({super.key, required this.round, required this.scores});

  @override
  State<RoundInputDialogue> createState() => _RoundInputDialogueState();
}

class _RoundInputDialogueState extends State<RoundInputDialogue> {
  late Map<User, int> scores;

  @override
  void initState() {
    scores = widget.scores.map((k, v) => MapEntry(k, v.scoreAt(widget.round)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Round ${widget.round}"),
      content: SingleChildScrollView(
        child: Table(
          children: scores.mapTo((k, v) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(k.name),
                      Text(scores[k]?.toString() ?? "0"),
                      k.toAvatar(),
                    ],
                  ),
                ),
                TextFormField(
                  initialValue: v.nullIfNotPositive?.toString() ?? "",
                  onChanged: (value) {
                    value = value.nullIfEmptyTrimmed ?? "0";
                    final x = int.tryParse(value);
                    if (x == null) return;

                    scores[k] = x;
                    setState(() {});
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.navigator.pop(), child: Text("Cancel")),
        TextButton(onPressed: () => context.navigator.pop(scores), child: Text("OK")),
      ],
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final Scorecard scorecard;

  const PdfPreviewScreen({super.key, required this.scorecard});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scorecard PDF')),
      body: PdfPreview(
        build: (format) async {
          final doc = scoreboardToPdf(scorecard);
          return doc.save();
        },
      ),
    );
  }
}