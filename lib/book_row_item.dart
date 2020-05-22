import 'package:flutter/cupertino.dart';

import 'model/book.dart';
import 'styles.dart';

class BookRowItem extends StatelessWidget {
  const BookRowItem({
    this.index,
    this.book,
    this.lastItem,
  });

  final Book book;
  final int index;
  final bool lastItem;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '[${book.shelf}]',
          ),
          const Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(
            child:  Text(
              book.toString(),
              style: Styles.bookRowItem,
            ),
          ),        
        ],
      ),
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Container(
          height: 1,
          color: Styles.bookRowDivider,
        ),
      ],
    );
  }
}