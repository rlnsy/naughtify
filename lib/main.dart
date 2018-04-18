import 'package:flutter/material.dart';

void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Naughtify',
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>{
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Naughtify'),
      ),
      body: new Center(
        child: new Text('stuff goes here'),
      ),
    );
  }
}