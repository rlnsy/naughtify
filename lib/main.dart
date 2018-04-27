import 'package:flutter/material.dart';

import 'platform_comm.dart';

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
  platformMethods pMethods = new platformMethods();

  Runes smiley = new Runes('\u{1f626}');

  int _numNotifications = 0;

  // TODO: redesign UI
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Naughtify'),
      ),
      body: new Center(
          child: new Column(
        children: <Widget>[
          new FutureBuilder<int>(
              future: pMethods.getNumNotifications(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _numNotifications = snapshot.data;
                } else if (snapshot.hasError) {
                  return new Text('error getting number of notifications');
                }
                return new Text(
                    'Naughtify has received ${_numNotifications} notifications ${new String
                            .fromCharCodes(smiley)}');
              }),
          new RaisedButton(
            onPressed: () {
              pMethods.sendNotification();
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
      )),
      floatingActionButton: new FloatingActionButton(
          onPressed: pMethods.clearNotifications,
          tooltip: 'Clear Notifications',
          child: new Icon(Icons.archive)),
    );
  }
}
