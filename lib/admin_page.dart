import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'model/book.dart';
import 'model/catalog_database.dart';
import 'model/ndl_search.dart';
import 'styles.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const List<String> _FIELDS = [
    'marcno',
    'shelf',
    'title',
    'pub',
    'isbn'
  ];

  final _formKey = GlobalKey<FormState>();
  int _bookId = -1;
  String _isbn;
  List<TextEditingController> _controllers;
  List<FocusNode> _fnodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List<TextEditingController>.generate(5, (i) => TextEditingController());
    _fnodes = List<FocusNode>.generate(5, (i) => FocusNode());
  }

  @override
  void dispose() {
    _fnodes.forEach((elm) => elm.dispose());
    _controllers.forEach((elm) => elm.dispose());
    super.dispose();
  }

  void onInsert() {
    CatalogDatabase catalog = CatalogDatabase();

    Book book = Book.fromDb({
      'marcno': _controllers[0].text,
      'shelf': _controllers[1].text,
      'title': _controllers[2].text,
      'pub': _controllers[3].text,
      'isbn': _controllers[4].text,
    });
    catalog.insert(book).then((regBook) {
      setState(() => _bookId = regBook.id);
      Fluttertoast.showToast(
        msg: '登録しました。',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.lightGreen[300],
        textColor: Colors.black,
      );
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
    Navigator.of(context)..pop();
  }

  Widget _buildField(int i, String field) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
            child: Text(field.toUpperCase()),
          ),
        ),
        Expanded(
          flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
            child: CupertinoTextField(
              controller: _controllers[i],
              focusNode: _fnodes[i],
              autofocus: i == 1 ? true : false,
              maxLines: i == 2 ? 3 : 1,
              keyboardType: TextInputType.text,
              onSubmitted: (v) => i == 4
                  ? FocusScope.of(context).requestFocus(FocusNode())
                  : FocusScope.of(context).requestFocus(_fnodes[i+1]),
            ),
          ),
        ),
      ],
    );
  }

  void _setText(TextEditingController controller, String value) {
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.fromPosition(
        TextPosition(offset: value.length),
      ),
    );
  }

  void _setFields(Map<String, String> rec) {
    _FIELDS.asMap().forEach((i, field) {
      _setText(_controllers[i], (rec[field] ?? ''));
    });
  }

  Widget _buildForm() {
    return FutureBuilder(
      future: NdlSearch.getRecord(_isbn),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: const CupertinoActivityIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else {
          if (snapshot.hasData) {
            _setFields(snapshot.data);
          } else {
            Map<String, String> empty =
                Map.fromIterable(_FIELDS, key: (e) => e, value: (e) => '');
            _setFields(empty);
          }
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10)),
                    const Text('レコード管理'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                        child: const Text('ID'),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 15, top: 10, bottom: 10),
                        child: Text('$_bookId'),
                      ),
                    ),
                  ],
                ),
                _buildField(0, 'marc'),
                _buildField(1, 'shelf'),
                _buildField(2, 'title'),
                _buildField(3, 'pub'),
                _buildField(4, 'isbn'),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CupertinoButton(
                          child: const Text('追加'),
                          onPressed: _bookId == -1 ? onInsert : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() => _isbn = ModalRoute.of(context).settings.arguments);

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Styles.scaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: const Text('鈴木家蔵書目録'),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Styles.scaffoldBackground,
        ),
        child: SafeArea(
          child: _buildForm(),
        ),
      ),
    );
  }
}
