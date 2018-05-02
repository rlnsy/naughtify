import 'package:flutter/material.dart';

import 'platform_comm.dart';
import 'notification_management.dart';
import 'package:intl/intl.dart';

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
  MainState createState() => new MainState();
}

class MainState extends State<HomePage> {
  PlatformMethods pMethods = new PlatformMethods();

  bool muted = false;

  NotificationManager manager = new NotificationManager(new PlatformMethods());
  Text notificationHistory = new Text("");

  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
              title: new Text('Naughtify - Basic Prototype'),
              bottom: new TabBar(tabs: [
                new Tab(icon: new Icon(Icons.do_not_disturb_alt)),
                new Tab(icon: new Icon(Icons.timeline)),
              ])),
          body: new TabBarView(children: [
            _buildMainBody(),
            _buildInfo(),
          ]),
          floatingActionButton: new FloatingActionButton(
              onPressed: pMethods.sendNotification,
              tooltip: 'Clear Notifications',
              child: new Icon(Icons.add)),
        ));
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
      return "yes - currently listening for notifications";
    else
      return "no";
  }

  // VIEW STUFF

  Widget _infoState = new Container();

  Widget _buildInfo() {
    return new FutureBuilder(
        future: manager.fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _infoState = _buildList();
          } else if (snapshot.hasError) {
            return new Text("there was an error getting notification info");
          }
          return _infoState;
        });
  }

  Widget _buildList() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();
          final index = i ~/ 2;
          if (index >= manager.getNumSessions()) {
            return new Container();
          } else {
            return _buildSessionView(manager.getSessions()[index]);
          }
        });
  }

  Widget _buildSessionView(Session s) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Sessions Information'),
            ),
            body: new Column(
              children: _buildNotificationViews(s),
            ),
          );
        }));
      },
      child: new Column(
        children: _buildNotificationViews(s),
      ),
    );
  }

  List<Widget> _buildNotificationViews(Session s) {
    List<Widget> views = new List<Widget>();
    views.add(new Text('Session: ${s.getStartTime()} to ${s.getEndTime()}'));
    views.add(new Text('Notifications receieved'));
    for (NotificationEntry n in s.notifications) {
      views.add(_buildNotificationView(n));
    }
    return views;
  }

  Widget _buildNotificationView(NotificationEntry n) {
    return new Text('${convertTime(n.timeCode)} : ${n.packageName}');
  }

  String convertTime(int millis) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(millis);

    var format = new DateFormat("Hm");
    var timeString = format.format(date);

    return timeString;
  }
}
