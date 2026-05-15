import 'package:collection/collection.dart';
import 'package:five_crowns/main.dart';
import 'package:five_crowns/scorecard.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/localpkg.dart';
import 'package:printing/printing.dart';
import 'package:styled_logger/styled_logger.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

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
    ) : /*SingleChildScrollView(
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
    );*/

    TableView.builder(
      alignment: Alignment.center,
      rowCount: scores.length + 2,
      columnCount: rounds.length + 3,
      pinnedRowCount: 1,
      pinnedColumnCount: 1,

      rowBuilder: (int row) {
        return TableSpan(
          extent: FixedTableSpanExtent(row == 0 ? 30 : (row == scores.length + 2 - 1 ? 40 : 90)),
        );
      },

      columnBuilder: (int column) {
        return TableSpan(
          extent: FixedTableSpanExtent(column == 0 ? 200 : (column == 1 ? 80 : 40)),
        );
      },

      cellBuilder: (context, vicinity) {
        if (vicinity.isAt(0, 0)) {
          return TableViewCell(
            child: SizedBox.shrink(),
          );
        }

        if (vicinity.row == 0) {
          final round = rounds.elementAtOrNullSafe(vicinity.column - 2);

          return TableViewCell(
            child: vicinity.column <= 1 ? SizedBox.shrink() : InkWell(
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
            ),
          );
        }

        if (vicinity.column <= 1 && vicinity.row != scores.length + 2 - 1) {
          final entry = scores.elementAtOrNullSafe(vicinity.row - 1);
          final order = tryCatch(() => scores.toList().indexWhere((x) => x.key == entry!.key));

          return TableViewCell(child: entry == null ? SizedBox.shrink() : Row(
            children: [
              vicinity.column == 1 ? Row(
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
                  if (order != null) Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () {
                          moveUser(order, order == 0 ? scores.length - 1 : order - 1);
                        }, icon: Icon(order == 0 ? Icons.u_turn_left : Icons.arrow_upward), color: Color.lerp(Theme.of(context).iconTheme.color, entry.key.themeColor, 0.3)),
                        IconButton(onPressed: () {
                          moveUser(order, order == scores.length - 1 ? 0 : order + 1);
                        }, icon: order == scores.length - 1 ? RotatedBox(quarterTurns: 2, child: Icon(Icons.u_turn_right)) : Icon(Icons.arrow_downward), color: Color.lerp(Theme.of(context).iconTheme.color, entry.key.themeColor, 0.3)),
                      ],
                    ),
                  ),
                ],
              ) : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: entry.key.toAvatar(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key.name, softWrap: true).fontSize(16),
                      Builder(
                        builder: (context) {
                          final value = entry.value.total;
                          return Text(value.toString()).fontSize(24).color(placeToColor(place(entry.value.total)));
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ));
        }

        if (vicinity.row == scores.length + 2 - 1) {
          final round = rounds.elementAtOrNullSafe(vicinity.column - 2);

          return TableViewCell(
            child: vicinity.column == 0 ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: () {
                  moveUser(0, 1);
                }, icon: Icon(Icons.arrow_downward)),
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
                IconButton(onPressed: () {
                  moveUser(0, scores.length - 1);
                }, icon: Icon(Icons.arrow_upward)),
              ],
            ) : round != null && round == currentRound ? IconButton(onPressed: () async {
              final currentTotal = scores.fold(0, (a, b) => a + b.value.total);
              final result = await showDialog<Map<User, int>>(context: context, builder: (context) => RoundInputDialogue(round: round, scores: Map.fromEntries(scores)));
              Logger.print("Found result of ${result.runtimeType} and ${result?.length} entries (currentTotal=$currentTotal, currentRound=$currentRound)");
              if (result == null) return;

              for (final x in result.entries) {
                widget.scorecard.scores[x.key]!.scores[round] = x.value;
                onModify();
              }

              if (currentTotal == 0 && currentRound != null && currentRound! < 13) currentRound = currentRound! + 1;
              setState(() {});
            }, icon: Icon(Icons.edit)) : SizedBox.shrink(),
          );
        }

        if (vicinity.column == rounds.length + 2) {
          return TableViewCell(child: SizedBox.shrink());
        }

        final entry = scores.elementAt(vicinity.row - 1);
        final r = rounds[vicinity.column - 2];
        final value = entry.value.scores[r] ?? 0;

        return TableViewCell(child: InkWell(
          onTap: () async {
            final result = await showDialog<int>(context: context, builder: (context) => ScoreInputDialogue(round: r, user: entry.key, current: value));
            if (result == null) return;

            widget.scorecard.scores[entry.key]!.scores[r] = result;
            setState(() {});
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 50,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text(value.toString()).fontSize(20).color((currentRound ?? rounds.max + 1) <= r ? null : scoreToColor(value))),
            ),
          ),
        ));
      },
    );
  }

  void moveUser(int fromIndex, int toIndex) {
    final entries = widget.scorecard.scores.entries.toList();
    final entry = entries.removeAt(fromIndex);

    entries.insert(toIndex, entry);
    widget.scorecard.scores..clear()..addEntries(entries);

    onModify();
    setState(() {});
  }
}

extension on TableVicinity {
  bool isAt(int r, int c) {
    return r == row && c == column;
  }
}

extension ElementAtOrNullSafe<T> on Iterable<T> {
  T? elementAtOrNullSafe(int i) {
    try {
      return elementAtOrNull(i);
    } catch (_) {
      return null;
    }
  }
}

class ScoreInputDialogue extends StatefulWidget {
  final int round;
  final int current;
  final User user;
  const ScoreInputDialogue({super.key, required this.round, required this.user, required this.current});

  @override
  State<ScoreInputDialogue> createState() => _ScoreInputDialogueState();
}

class _ScoreInputDialogueState extends State<ScoreInputDialogue> {
  FocusNode node = FocusNode();
  late int score;

  @override
  void initState() {
    score = widget.current;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      node.requestFocus();
    });
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Round ${widget.round} for ${widget.user.name} - $score"),
      content: TextFormField(
        focusNode: node,
        initialValue: widget.current == 0 ? "" : widget.current.toString(),
        onChanged: (value) {
          final x = int.tryParse(value);
          if (x == null) return;

          score = x;
          setState(() {});
        },
      ),
      actions: [
        TextButton(onPressed: () => context.navigator.pop(), child: Text("Cancel")),
        TextButton(onPressed: () => context.navigator.pop(score), child: Text("OK")),
      ],
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