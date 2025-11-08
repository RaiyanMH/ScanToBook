import 'dart:typed_data';

class PageModel {
  final String id;
  String imagePath;
  Uint8List? imageBytes;
  bool isBookmarked;
  String? note;

  PageModel({
    required this.id,
    required this.imagePath,
    this.imageBytes,
    this.isBookmarked = false,
    this.note,
  });
} 