import 'package:five_crowns/scorecard.dart';
import 'package:five_crowns/scorecard_widget.dart';
import 'package:flutter/material.dart';
import 'package:localpkg_flutter/functions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final demoScorecard = Scorecard({
    User("John"): Scores({
      3: 0,
      4: 62,
      5: 91,
    }),
    User("Bob"): Scores({
      3: 954,
      4: 0,
      5: 32,
    }),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Five Crowns Scorecard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
      ),
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
    scorecard = MyApp.demoScorecard;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Five Crowns Scorecard"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async {
            final result = await showDialog<Scorecard>(context: context, builder: (context) => NewScorecardDialogue(defaultUsers: scorecard.scores.keys.map((x) => x.name).toList()));
            if (result == null) return;

            scorecard = result;
            setState(() {});
          }, icon: Icon(Icons.note_add)),
        ],
      ),
      body: ScorecardWidget(scorecard: scorecard),
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
      title: Text("New Scoreboard"),
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
          context.navigator.pop();
        }, child: Text("Cancel")),
        TextButton(onPressed: () {
          context.navigator.pop(Scorecard.fromUsers(users.map((x) => User(x)).toList()));
        }, child: Text("Create")),
      ],
    );
  }
}