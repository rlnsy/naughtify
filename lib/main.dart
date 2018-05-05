import 'package:flutter/material.dart';

import 'platform_comm.dart';
import 'notification_management.dart';

void main() => runApp(new App());

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    NotificationStorage storage = new NotificationStorage();
    PlatformMethods pMethods = new PlatformMethods();
    NotificationManager manager = new NotificationManager(pMethods, storage);

    return new MaterialApp(
      title: 'Naughtify',
      theme: new ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: new HomePage(
          storage: storage, pMethods: pMethods, manager: manager),
    );

  }
}

class HomePage extends StatefulWidget {

  final NotificationStorage storage;
  final PlatformMethods pMethods;
  final NotificationManager manager;

  HomePage({Key key, this.storage, this.pMethods, this.manager}) : super(key: key);

  MainState createState() => new MainState();
}

class MainState extends State<HomePage> {

  bool muted = false;

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
              onPressed: widget.pMethods.sendNotification,
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
    widget.pMethods.toggleMuteMode();
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

    // TODO: make all this better

    Widget mainView = new FutureBuilder(
        future: widget.manager.decodeNewNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _infoState = _buildList();
          } else if (snapshot.hasError) {
            return new Text("there was an error getting notification info");
          }
          return _infoState;
        });

    if (widget.manager.notLoaded()) {
      return new FutureBuilder(
          future: widget.manager.decodeFromFile(),
          builder: (context,snapshot) {
            if (snapshot.hasData) {
              return mainView;
            } else if (snapshot.hasError) {
              return new Text('error loading history');
            } else {
              return new Text('loading history from storage');
            }
          });
    } else {
      return mainView;
    }

  }

  Widget _buildList() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();
          final index = i ~/ 2;
          if (index >= widget.manager.getNumSessions()) {
            return new Container();
          } else {
            return _buildSessionView(widget.manager.getSessions()[index]);
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
    for (NotificationEntry n in s.getNotifications()) {
      views.add(_buildNotificationView(n));
    }
    return views;
  }

  Widget _buildNotificationView(NotificationEntry n) {
    return new Text('${Utilities.convertTime(n.timeCode)} : ${n.packageName}');
  }
}
