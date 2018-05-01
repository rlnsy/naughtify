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
  _MainState createState() => new _MainState();
}

class _MainState extends State<HomePage> {
  PlatformMethods pMethods = new PlatformMethods();

  bool muted = false;

  int _numReceieved = 0;

  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
              title: new Text('Naughtify - Basic Prototype'),
              bottom: new TabBar(tabs: [
                new Tab(icon: new Icon(Icons.directions_bike)),
                new Tab(icon: new Icon(Icons.directions_car)),
                // TODO: make icons
              ])),
          body: new TabBarView(children: [
            _buildMainBody(),
            _buildInfoBody(),
          ]),
          floatingActionButton: new FloatingActionButton(
              onPressed: pMethods.sendNotification,
              tooltip: 'Clear Notifications',
              child: new Icon(Icons.add)),
        ));
  }

  Widget _buildInfoBody() {
    return new FutureBuilder(
        future: pMethods.getNumNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _numReceieved = snapshot.data;
          } else if (snapshot.hasError) {
            return new Text("there was an error getting notification info");
          }
          return new Text("notifications received: $_numReceieved");
        });
  }

  Widget _buildMainBody() {
    return new Center(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new RaisedButton(
            child: new Text("toggle mute"), onPressed: _toggleMute),
        new Text("muted: ${_isMuted()}"),
      ],
    ));
  }

  _toggleMute() {
    bool newValue;
    if (muted) {
      newValue = false;
    } else {
      newValue = true;
    }
    pMethods.toggleMuteMode();
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
