import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:five_crowns/scorecard.dart';
import 'package:five_crowns/scorecard_widget.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_logger/styled_logger.dart';

late SharedPreferences prefs;
Scorecard? loaded;

void main() async {
  Logger.enable();
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  loaded = Scorecard.fromJsonSafe(prefs.getString("current") ?? "");

  Logger.print("Loaded scorecard: ${loaded.runtimeType}");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final demoScorecard = Scorecard({});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Five Crowns Scorecard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData.dark(),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Scorecard scorecard;

  @override
  void initState() {
    scorecard = loaded ?? MyApp.demoScorecard;
    super.initState();
  }

  void onModify() {
    Logger.print("Scorecard modified");
    prefs.setString("current", jsonEncode(scorecard.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Five Crowns Scorecard"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfPreviewScreen(scorecard: scorecard),
              ),
            );
          }, icon: Icon(Icons.share)),
          IconButton(onPressed: () async {
            final result = await showDialog<Scorecard>(context: context, builder: (context) => NewScorecardDialogue(defaultUsers: scorecard.scores.keys.map((x) => x.name).toList()));
            if (result == null) return;

            scorecard = result;
            onModify();
            setState(() {});
          }, icon: Icon(Icons.note_add)),
        ],
      ),
      body: Center(child: ScorecardWidget(scorecard: scorecard, onModify: onModify)),
    );
  }
}

class NewScorecardDialogue extends StatefulWidget {
  final List<String>? defaultUsers;
  const NewScorecardDialogue({super.key, this.defaultUsers});

  @override
  State<NewScorecardDialogue> createState() => _NewScorecardDialogueState();
}

class _NewScorecardDialogueState extends State<NewScorecardDialogue> {
  final controller = TextEditingController();
  List<String> users = [];

  @override
  void initState() {
    users.addAll(widget.defaultUsers ?? []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("New Scorecard"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Add a user'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        users.add(controller.text);
                        controller.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(users[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => users.removeAt(i)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          context.navigator.pop(Scorecard({}));
        }, child: Text("Clear")),
        TextButton(onPressed: () {
          context.navigator.pop();
        }, child: Text("Cancel")),
        TextButton(onPressed: () {
          context.navigator.pop(Scorecard.fromUsers(users.map((x) => User(x)).toList()));
        }, child: Text("Create")),
      ],
    );
  }
}

extension MapTo<K, V> on Map<K, V> {
  Iterable<T> mapTo<T>(T Function(K key, V value) callback) {
    return entries.map<T>((e) => callback.call(e.key, e.value));
  }
}

extension MapList<T> on List<T> {
  List<R> mapList<R>(R Function(T item) convert) {
    return mapIndexed((i, x) => convert.call(x)).toList();
  }
}
