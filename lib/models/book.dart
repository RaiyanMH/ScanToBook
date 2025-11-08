import 'dart:typed_data';
import 'page_model.dart';

class Book {
  final String id;
  String title;
  String? coverImagePath;
  Uint8List? coverBytes;
  List<PageModel> pages;
  DateTime createdAt;
  DateTime updatedAt;
  int? lastReadPageIndex;
  bool? isRightToLeft;
  bool? isVerticalScroll;
  bool? reversePageOrder;

  Book({
    required this.id,
    required this.title,
    this.coverImagePath,
    this.coverBytes,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
    this.lastReadPageIndex,
    this.isRightToLeft,
    this.isVerticalScroll,
    this.reversePageOrder,
  });
} 