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
        primarySwatch: Colors.cyan,
      ),
      home:
          new HomePage(storage: storage, pMethods: pMethods, manager: manager),
    );
  }
}

class HomePage extends StatefulWidget {
  final NotificationStorage storage;
  final PlatformMethods pMethods;
  final NotificationManager manager;

  HomePage({Key key, this.storage, this.pMethods, this.manager})
      : super(key: key);

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
              title: new Text('Naughtify'),
              actions: <Widget>[
                new IconButton(
                    icon: new Icon(Icons.settings), onPressed: _pushSettings),
              ],
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

  void _pushSettings() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('App Settings'),
          ),
          body: new Column(
            children: <Widget>[
              new Text('click the button to erase history'),
              new RaisedButton(
                  onPressed: widget.manager.eraseHistory,
                  child: new Text('erase')),
            ],
          ));
    }));
  }

  Widget _buildMainBody() {
    return new Center(
        child: new Column(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Text(
            'Toggle mute on or off',
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        new Expanded(
            child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Switch(
                value: muted,
                onChanged: (bool val) {
                  setState(() {
                    muted = val;
                  });
                  widget.pMethods.toggleMuteMode();
                }),
            new Text('${_listening()}')
          ],
        ))
      ],
    ));
  }

  String _listening() {
    if (muted) return 'listening for notifications...';
    return '';
  }

  String _toggleStatus() {
    if (muted) return 'mute on';
    return 'mute off';
  }

  // VIEW STUFF

  Widget _infoState = new Container();

  Widget _buildInfo() {
    // TODO: make all this better

    Widget mainView = new Column(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.all(8.0),
          child: new Text(
            'Notification Session History',
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        new Expanded(
            child: new FutureBuilder(
                future: widget.manager.decodeNewNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _infoState = _buildList();
                  } else if (snapshot.hasError) {
                    return new Text(
                        "there was an error getting notification info");
                  }
                  return _infoState;
                }))
      ],
    );

    if (widget.manager.notLoaded()) {
      return new FutureBuilder(
          future: widget.manager.decodeFromFile(),
          builder: (context, snapshot) {
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
    return new ListView(
      children: _buildSessionsEntries(),
    );
  }

  List<Widget> _buildSessionsEntries() {
    List<Widget> entries = new List<Widget>();
    for (Session s in widget.manager.getSessions()) {
      entries.add(_buildSessionView(s));
    }
    return entries;
  }

  Widget _buildSessionView(Session s) {
    return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return new Scaffold(
              appBar: new AppBar(
                title: const Text('Notifications'),
              ),
              body: _buildSessionDetail(s),
            );
          }));
        },
        child: new Card(
            child: new ListTile(
          title: new Text('${s.getStartTime()} to ${s.getEndTime()}'),
          subtitle:
              new Text('${s.getNumNotifications()} notifications received'),
        )));
  }

  Widget _buildSessionDetail(Session s) {

    // TODO: fix overflow

    List<Widget> views = new List<Widget>();

    for (NotificationEntry n in s.getNotifications()) {
      views.add(_buildNotificationView(n));
      views.add(new Text('${Utilities.convertTime(n.timeCode)}'));
    }
    return new Column(
      children: views,
    );
  }

  Widget _buildNotificationView(NotificationEntry n) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return _buildDetailedNotificationView(n);
        }));
      },
      child: new Card(
          child: new ListTile(
        leading: new FutureBuilder(
            future: n.getPackIcon(widget.storage),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              } else {
                return new Icon(Icons.file_upload); // placeholder
              }
            }),
        title: new Text('${n.title}'),
        subtitle: new Text(n.text),
      )),
    );
  }

  Widget _buildDetailedNotificationView(NotificationEntry n) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Notification Details'),
      ),
      body: new Text(
          'time: ${Utilities.convertTime(n.timeCode)}\npackage: "${n.packageName}"\n'
          'title: "${n.title}"\ntext: "${n.text}"'),
    );
  }
}
