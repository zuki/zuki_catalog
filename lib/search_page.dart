import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'search_bar.dart';
import 'row_item.dart';
import 'styles.dart';
import 'utils.dart';
import 'model/catalog.dart';
import 'model/catalog_database.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.model}) : super(key: key);

  final CatalogModel model;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller;
  FocusNode _focusNode;
  String _terms = '';
  String _errMessage = '';
 
  void _showModalPopupOnNoHit() {
    final status = widget.model.status;
    if (status is CatalogStatusNoHit) {
      if (!Utils.isIsbn(_terms)) {
        return;
      }
      final act = CupertinoActionSheet(
        title: const Text('該当図書はありません。'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: const Text('追加する'),
            onPressed: () {
              final terms = _terms;
              _setText('');
              Navigator.of(context)..pop()..pop();
              Navigator.pushNamed(
                context, '/admin', 
                arguments: terms,
              );
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('追加しない'),
          isDefaultAction: true,
          onPressed: () {
            _setText('');
            Navigator.of(context)..pop()..pop();
          },
        ),
      );
      //widget.model.clear();
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => act,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_showModalPopupOnNoHit);
    _controller = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    widget.model.removeListener(_showModalPopupOnNoHit);
    super.dispose();
  }

  void _onDelete(int id) {
    CatalogDatabase catalog = CatalogDatabase();

    catalog.delete(id).then((count) {
      Fluttertoast.showToast(
        msg: '削除しました',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.pink[100],
        textColor: Colors.black,
      );
      _setText('');
      FocusScope.of(context).requestFocus(FocusNode());
    }).catchError((e) {
      Fluttertoast.showToast(
          msg: 'id: $id は削除できませんでした。\n\n${e.toString()}');
    });
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controller.text;
    });
  }

  void _setText(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.fromPosition(
        TextPosition(offset: value.length),
      ),
    );
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
      widget.model.search(_terms);
      return ScopedModel<CatalogModel>(
        model: widget.model,
        child: ScopedModelDescendant<CatalogModel>(
          builder: (context, child, model) {
            final status = model.status;
            if (status is CatalogStatusLoading) {
              return const CupertinoActivityIndicator();
            } else if (status is CatalogStatusFailure) {
              return Text('検索エラー(${status.error.toString()})が発生しました。');
            } else if (status is CatalogStatusSuccess) {
              return Column(
                children: <Widget>[
                  Text('件数: ${status.results.length}'),
                  const Divider(),
                  SizedBox(
                    height: 670,
                    child: ListView.builder(
                      itemCount: status.results.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          key: Key(status.results[index].id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _onDelete(status.results[index].id);
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            color: Colors.redAccent[700],
                            child: const Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                              child: const Icon(
                                CupertinoIcons.delete_solid,
                                color: Colors.white
                              ),
                            ),
                          ),
                          child: RowItem(
                            key: Key(status.results[index].id.toString()),
                            index: index,
                            book: status.results[index],
                            lastItem: index == status.results.length - 1,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (status is CatalogStatusNoHit) {
              return const Text('該当図書はありません。');
            } else {
              return const Text('');
            }
          },
        ),
      );
    }
  }

  void barcodeScanning() {
    final options = ScanOptions(
      restrictFormat: [BarcodeFormat.ean13],
    );
    final future = BarcodeScanner.scan(options: options);
    future.then((result) {
      final isbn = Utils.isbn13(result.rawContent);
      setState(() => _setText(isbn));
    }).catchError((e) {
      setState(() {
        _errMessage = (e.code == BarcodeScanner.cameraAccessDenied)
            ? 'バーコードスキャンにはカメラの使用を許可してください。'
            : '不明なエラー($e)が発生しました。';
      });
    });
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
