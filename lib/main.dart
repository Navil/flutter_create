import 'dart:convert';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Event {
  Event({this.name, this.year});
  final String name;
  final int year;
  bool bCorrect;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(name: json['name'], year: json['year']);
  }
}

class GameWidget extends StatefulWidget {
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> with TickerProviderStateMixin {
  List<Event> events = List<Event>();
  bool bShowResult = false;

  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flutter Create - Thomas Anderl",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orangeAccent,
        ),
        body: Container(
          child: FutureBuilder(
              future: DefaultAssetBundle.of(context)
                  .loadString("assets/history.json"),
              builder: (context, snapshot) {
                parseJson(snapshot.data.toString());
                return events.isNotEmpty
                    ? buildList()
                    : Center(child: CircularProgressIndicator());
              }),
        ));
  }

  Widget buildListTile(Event item) {
    return Container(
      key: Key(item.name),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: Colors.yellow),
      margin: EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: ListTile(
          subtitle: bShowResult
              ? Text(
                  item.bCorrect ? "Correct" : "Wrong",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: item.bCorrect ? Colors.green : Colors.red),
                )
              : null,
          title: Text(
            item.name,
            textAlign: TextAlign.center,
          ),
          leading: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.yellow,
              child: Text(bShowResult ? item.year.toString() : "?"))),
    );
  }

  Widget buildList() {
    return Column(
      children: [
        SizedBox(height: 10),
        Flexible(
          child: FadeTransition(
            opacity: animation,
            child: ReorderableListView(
              header: Text(
                'Drag into ascending order!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              children:
                  events.sublist(0, 5).map<Widget>(buildListTile).toList(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final Event item = events.removeAt(oldIndex);
                  events.insert(newIndex, item);
                });
              },
            ),
          ),
        ),
        Container(
          width: 200.0,
          height: 50.0,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
          child: RaisedButton(
            child: Text(bShowResult ? 'Restart' : 'Check'),
            color: Colors.yellow,
            onPressed: () {
              setState(() {
                if (bShowResult)
                  restartGame();
                else {
                  List<Event> result = List<Event>()
                    ..addAll(events.sublist(0, 5))
                    ..sort((Event a, Event b) {
                      return a.year.compareTo(b.year);
                    });
                  for (int i = 0; i < result.length; i++)
                    events[i].bCorrect = events[i].year == result[i].year;
                }
                bShowResult = !bShowResult;
              });
            },
          ),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  void parseJson(String response) {
    dynamic decoded = json.decode(response);
    if (events.isEmpty && decoded != null) {
      events = decoded
          .cast<Map<String, dynamic>>()
          .map<Event>((json) => Event.fromJson(json))
          .toList();
      restartGame();
    }
  }

  void restartGame() {
    controller.forward(from: 0);
    events.shuffle();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Oswald', canvasColor: Colors.greenAccent),
      home: GameWidget(),
    );
  }
}
