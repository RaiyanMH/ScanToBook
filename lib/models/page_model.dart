import 'dart:typed_data';

class PageModel {
  final String id;
  String imagePath;
  Uint8List? imageBytes;
  bool isBookmarked;
  String? note;
  String? chapterId; // ID of the chapter this page belongs to

  PageModel({
    required this.id,
    required this.imagePath,
    this.imageBytes,
    this.isBookmarked = false,
    this.note,
    this.chapterId,
  });
} 