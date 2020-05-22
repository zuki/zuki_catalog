import 'package:flutter/foundation.dart';

class Book {
  Book({
    @required this.id,
    this.marcno,
    this.shelf,
    this.title,
    this.pub,
    this.isbn,
  }) : assert(id != null);

  int id;
  String marcno;
  String shelf;
  String title;
  String pub;
  String isbn;

  @override
  String toString() => '$title - $pub' + (isbn != '' ? ' ($isbn)' : '');

  Map<String, dynamic> toMapForDb() {
    var map = Map<String, dynamic>();
    map['id']     = id;
    map['marcno'] = marcno ?? '';
    map['shelf']  = shelf ?? '';
    map['title']  = title ?? '';
    map['pub']    = pub ?? '';
    map['isbn']   = isbn ?? '';
    return map;
  }

  Book.fromDb(Map<String, dynamic> map) {
    id     = map['id'];
    marcno = map['marcno'] ?? '';
    shelf  = map['shelf']  ?? '';
    title  = map['title']  ?? '';
    pub    = map['pub']    ?? '';
    isbn   = map['isbn']   ?? '';
  }

}