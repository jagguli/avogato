import 'dart:io';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:developer' as developer;
import 'imagebtn.dart';
import 'package:zeroconf/zeroconf.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Websocket Grid App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  IOWebSocketChannel? _channel;
    Map<String, dynamic> _launchers = {};
  bool _isLoading = false;
  bool _isConnected = false;
  bool _connectionError = false;

  @override
  void initState() {
    super.initState();
    _connectWebsocket();
  }

  void _listenWebsocket() {
    _channel!.sink?.add(json.encode({
      'cmd': "launchers",
    }));
    _channel!.stream?.listen((data) {
      setState(() {
        _isConnected = true;
        try {
          Map<String, dynamic> response = json.decode(data);
          if (response.containsKey("launchers")) {
            _launchers = response.remove("launchers");
          } else {
            print(response);
          }
        } catch (error) {
          print(error);

          _launchers = {};
        }
      });
    }, onDone: () {
      _connectWebsocket();
    });
  }

  void _connectWebsocket() {
    try {
      _channel = IOWebSocketChannel.connect("ws://threadripper0:9990");
      _listenWebsocket();
    } on SocketException catch (e) {
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
      showErrorDialog(context, 'Websocket Connection Error',
          'Failed to connect to websocket: $e');
    } on HandshakeException catch (e) {
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
      showErrorDialog(context, 'Websocket Connection Error',
          'Failed to connect to websocket: $e');
    }
    ;
  }

  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _reconnectWebsocket() {
    if (!_isConnected) {
      print("reconnecting");
      _connectWebsocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return _launchers == {}
              ? _errorScreen()
              : Container(
                  padding: EdgeInsets.all(10.0),
                  child: GridView.count(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
                    children: _launchers.entries.map((entry){
                    print('icon me $entry');
                      return ImageButton(
                        imageBase64: entry.value['icon'] ?? "default",
                        onPressed: () =>
                            _sendIndex(entry.key.toLowerCase()),
                        label: entry.key,
                      );
                      }
                    ).toList(),
                  ),
                );
        },
      ),
    );
  }

  void _sendIndex(String index) {
    _reconnectWebsocket();
    print('sending me $index');

    _channel!.sink?.add(json.encode({
      'key': index,
    }));
  }

  Widget _errorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Error parsing data'),
        SizedBox(
          height: 10.0,
        ),
        ElevatedButton(
          onPressed: _reconnectWebsocket,
          child: Text('Retry'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _channel!.sink?.close();
    super.dispose();
  }
}
