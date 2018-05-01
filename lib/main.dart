import 'package:flutter/material.dart';

import 'platform_comm.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Naughtify',
      theme: new ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlatformMethods pMethods = new PlatformMethods();

  bool muted = false;

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Naughtify - Basic Prototype'),
      ),
      body: new Center(
          child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new RaisedButton(
              child: new Text("toggle mute"), onPressed: _toggleMute),
          new Text("muted: ${_isMuted()}"),
        ],
      )),
      floatingActionButton: new FloatingActionButton(
          onPressed: pMethods.sendNotification,
          tooltip: 'Clear Notifications',
          child: new Icon(Icons.add)),
    );
  }

  _toggleMute() {
    bool newValue;
    if (muted) {
      newValue = false;
    } else {
      newValue = true;
    }
    setState(() {
      muted = newValue;
    });
  }

  String _isMuted() {
    if (muted)
      return "yes";
    else
      return "no";
  }
}
