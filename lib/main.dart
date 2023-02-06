import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _launchers = [];
  IOWebSocketChannel? _channel;
  bool _connectionError = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    _channel = IOWebSocketChannel.connect('ws://threadripper0:9999/ws');
    if (_channel != null && _channel!.stream != null) {
    _channel!.sink?.add("launchers");
      _channel!.stream?.listen((data) {
        setState(() {
          _launchers = jsonDecode(data) as List;
          _connectionError = false;
        });
      }, onError: (error) {
        setState(() {
          _connectionError = true;
        });
      });
    } else {
      setState(() {
          _connectionError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            title: Text('Flutter GridView Example'),
            elevation: 0.0,
          ),
        ),
        body: (_connectionError)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("WebSocket connection failed"),
                    ElevatedButton(
                      child: Text("Retry"),
                      onPressed: () {
                        setState(() {
                          _connectionError = false;
                        });
                        _connect();
                      },
                    ),
                  ],
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                children: (_launchers == null)
                    ? [CircularProgressIndicator()]
                    : _launchers.map((launcher) {
                        return Container(
                          padding: EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_channel != null) {
                                _channel!.sink?.add(jsonEncode(launcher));
                              }
                            },
                            child: Text(launcher['label']),
                          ),
                        );
                      }).toList(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

