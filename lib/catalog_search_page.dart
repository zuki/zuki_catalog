import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'search_bar.dart';
import 'book_row_item.dart';
import 'styles.dart';
import 'model/book.dart';
import 'model/catalog_database.dart';

class CatalogSearchPage extends StatefulWidget {
  @override
  _CatalogSearchState createState() {
    return _CatalogSearchState();
  }
}

class _CatalogSearchState extends State<CatalogSearchPage> {
  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
    });
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SearchBar(
        controller: _controller,
        focusNode: _focusNode,
      ),
    );
  }

  Widget _buildResults() {
    final model = CatalogDatabase();
    if (_terms == '') {
      return Text('');
    } else {
      return Expanded(
        child: SizedBox(
          height: 200.0,
          child: FutureBuilder(
            future: model.search(_terms),
            builder:
                (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return CupertinoActivityIndicator();
              }
              if (snapshot.hasError) {
                return Text('エラーが発生しました。');
              }

              if (snapshot.hasData) {
                return ListView.builder(
                  itemBuilder: (context, index) => BookRowItem(
                    index: index,
                    book: snapshot.data[index],
                    lastItem: index == snapshot.data.length - 1,
                  ),
                  itemCount: snapshot.data.length,
                );
              } else {
                return Text('該当図書はありません。');
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Styles.scaffoldBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBox(),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}
