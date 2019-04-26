import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:async';

void main() => runApp(SampleApp());

class SampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: SampleAppPage(),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  List widgets = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample App'),
      ),
      body: _getBody(),
    );
  }

  bool _showLoadingDialog() {
    if (widgets.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget _getProgressDialog() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView _getListView() => ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int position) {
        return _getRow(position);
      });

  Widget _getBody() {
    if (_showLoadingDialog()) {
      return _getProgressDialog();
    } else {
      return _getListView();
    }
  }

  Widget _getRow(int index) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('Row ${widgets[index]["title"]}'),
    );
  }

  loadData() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(dataLoader, receivePort.sendPort);

    SendPort sendPort = await receivePort.first;

    List msg = await sendReceive(
        sendPort, 'https://jsonplaceholder.typicode.com/posts');

    setState(() {
      widgets = msg;
    });
  }

  static dataLoader(SendPort sendPort) async {
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (var msg in port) {
      String data = msg[0];
      SendPort replyTo = msg[1];

      String dataURL = data;
      HttpClient httpClient = HttpClient();
      try {
        HttpClientRequest request = await httpClient.getUrl(Uri.parse(dataURL));
        HttpClientResponse response = await request.close();
        if (response.statusCode == HttpStatus.ok) {
          String json = await response.transform(utf8.decoder).join();
          replyTo.send(jsonDecode(json));
        } else {
          print(
              'Error getting IP address:\nHttp status ${response.statusCode}');
        }
      } catch (exception) {
        print('Failed getting IP address');
      }
    }
  }

  Future sendReceive(SendPort port, msg) {
    ReceivePort response = ReceivePort();
    port.send([msg, response.sendPort]);
    return response.first;
  }

/**
  loadData() async {
    String dataURL = 'https://jsonplaceholder.typicode.com/posts';
    HttpClient httpClient = HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(dataURL));
      HttpClientResponse response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        setState(() {
          widgets = jsonDecode(json);
        });
      } else {
        print('Error getting IP address:\nHttp status ${response.statusCode}');
      }
    } catch (exception) {
      print('Failed getting IP address');
    }
  }
  */
}
