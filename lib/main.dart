import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:local_notifications/local_notifications.dart';

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

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('com.rowlindsay/notification');

  Runes smiley = new Runes('\u{1f626}');

  int _numNotifications = 0;

  int _notID = 0;

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Naughtify'),
      ),
      body: new Center(
          child: new Column(
            children: <Widget>[
              new FutureBuilder<int>(
                future: _getNumNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _numNotifications = snapshot.data;
                  } else if (snapshot.hasError) {
                    return new Text('error getting number of notifications');
                  }
                  return new Text('Naughtify has received ${_numNotifications} notifications ${new String.fromCharCodes(smiley)}');
                }
              ),
              new RaisedButton(
                onPressed: () {
                  _sendNotification();
                },
                child: new Text('send a notification'),
              ),
              new RaisedButton(
                onPressed: () {
                  setState(() {});
                },
                color: Colors.pink,
                child: new Text('refresh'),
              )
            ],
        )
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: _clearNotifications,
          tooltip: 'Clear Notifications',
          child: new Icon(Icons.archive)),
    );
  }

  // TODO: figure out why this doesn't work

  _clearNotifications() async {
    try {
      await platform.invokeMethod('clearNotifications');
    } on PlatformException catch (e) {
      print('could not clear');
    }
  }

  Future<int> _getNumNotifications() async {
    int num;
    try {
      num = await platform.invokeMethod('getNumNotifications');
    } on PlatformException catch (e) {
      num = -1;
    }
    return num;
  }

  _sendNotification() {
    LocalNotifications.createNotification(
        title: "Basic", content: "Notification", id: _notID);
    setState(() {
      _notID++;
    });
  }
}
