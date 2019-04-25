import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

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
      body: ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (BuildContext context, int position) {
          return _getRow(position);
        },
      ),
    );
  }

  Widget _getRow(int index) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text('Row ${widgets[index]["title"]}'),
    );
  }

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
}
