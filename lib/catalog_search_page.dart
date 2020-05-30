import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

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
  String _errMessage = '';

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
      return const Text('');
    } else if (_errMessage != '') {
      return CupertinoAlertDialog(
        title: const Text("エラー"),
        content: Text(_errMessage),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => setState(() => _errMessage = ''),
          ),
        ],
      );
    } else {
      return FutureBuilder(
        future: (isIsbn(_terms)
            ? model.searchByIsbn(_terms)
            : model.search(_terms)),
        builder: (BuildContext context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CupertinoActivityIndicator();
          }
          if (snapshot.hasError) {
            return const Text('検索エラーが発生しました。');
          }
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Text('件数: ${snapshot.data.length}'),
                const Divider(),
                SizedBox(
                  height: 670,
                  child: ListView.builder(
                    itemBuilder: (context, index) => BookRowItem(
                      key: Key(index.toString()),
                      index: index,
                      book: snapshot.data[index],
                      lastItem: index == snapshot.data.length - 1,
                    ),
                    itemCount: snapshot.data.length,
                  ),
                ),
              ],
            );
          } else {
            return const Text('該当図書はありません。');
          }
        },
      );
    }
  }

  bool isIsbn(String value) {
    if (value.length != 13) {
      return false;
    }
    return int.tryParse(value) != null;
  }

  void barcodeScanning() {
    final options = ScanOptions(
      restrictFormat: [BarcodeFormat.ean13],
    );
    final future = BarcodeScanner.scan(options: options);
    future.then((result) {
      setState(() {
        final isbn = isbn13(result.rawContent);
        _controller.value = TextEditingValue(
          text: isbn,
          selection: TextSelection.fromPosition(
            TextPosition(offset: isbn.length),
          ),
        );
      });
    }).catchError((e) {
      setState(() {
        _errMessage = (e.code == BarcodeScanner.cameraAccessDenied)
            ? 'バーコードスキャンにはカメラの使用を許可してください。'
            : '不明なエラー($e)が発生しました。';
      });
    });
  }

  String isbn13(String isbn) {
    if (isbn.length == 13) {
      return isbn;
    }
    const NUMVALUES = "0123456789";
    final digits = "978$isbn".split('');
    var sum = 0;
    for (int i = 0; i < 12; i++) {
      final val = NUMVALUES.indexOf(digits[i]);
      sum += val * (i % 2 == 0 ? 1 : 3);
    }
    final chk = (sum % 10 == 0) ? "0" : (10 - (sum % 10)).toString();
    return "978$isbn$chk";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Styles.scaffoldBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('鈴木家蔵書目録'),
        trailing: GestureDetector(
          onTap: () {
            barcodeScanning();
          },
          child: const Icon(CupertinoIcons.photo_camera),
        ),
      ),
      child: DecoratedBox(
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
      ),
    );
  }
}
