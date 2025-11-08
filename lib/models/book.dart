import 'dart:typed_data';
import 'page_model.dart';
import 'chapter.dart';

class Book {
  final String id;
  String title;
  String? coverImagePath;
  Uint8List? coverBytes;
  List<PageModel> pages;
  List<Chapter> chapters; // List of chapters
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
    this.chapters = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastReadPageIndex,
    this.isRightToLeft,
    this.isVerticalScroll,
    this.reversePageOrder,
  });
} 