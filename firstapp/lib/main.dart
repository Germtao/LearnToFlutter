import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firstapp/category_route.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new RandomWords(),
    );
  }
}

// 有状态的 widget
class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => new _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _save = new Set<WordPair>(); // 收藏 Set - 不会有重复数据
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext _context, int i) {
        // 在每一列之前, 添加一个1像素高的分割线widget
        if (i.isOdd) {
          return new Divider();
        }

        final int index = i ~/ 2; // 语法 "i ~/ 2" 表示i除以2，但返回值是整形（向下取整)
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair wordPair) {
    final bool alreadySaved = _save.contains(wordPair);
    return ListTile(
      title: new Text(wordPair.asPascalCase, style: _biggerFont),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _save.remove(wordPair);
          } else {
            _save.add(wordPair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    // Navigator.of(context).push(new MaterialPageRoute(
    //   builder: (BuildContext context) {
    //     final Iterable<ListTile> tiles = _save.map((WordPair wordPair) {
    //       return new ListTile(
    //         title: new Text(
    //           wordPair.asPascalCase,
    //           style: _biggerFont,
    //         ),
    //       );
    //     });
    //     final List<Widget> divider =
    //         ListTile.divideTiles(context: context, tiles: tiles).toList();

    //     return new Scaffold(
    //       appBar: new AppBar(
    //         title: const Text('Saved Suggestions'),
    //       ),
    //       body: new ListView(
    //         children: divider,
    //       ),
    //     );
    //   },
    // ));
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) {
        return new CategoryRoute();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Startup Name Generator'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
          )
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}
