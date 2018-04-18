import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Naughtify',
      theme: new ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>{

  static const platform = const MethodChannel('com.rowlindsay/notification');

  Runes smiley = new Runes('\u{1f607}');

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Naughtify'),
      ),
      body: new Center(
        child: new Text('click the button to clear all notifications now ${new String.fromCharCodes(smiley)}'),
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: _clearNotifications,
          tooltip: 'Clear Notifications',
          child: new Icon(Icons.archive)),
    );
  }


  Future<Null> _clearNotifications() async {
    try {
      await platform.invokeMethod('clearNotifications');
    } on PlatformException catch (e) {
      // method didn't work
    }
  }
}