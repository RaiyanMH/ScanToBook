import 'package:flutter/material.dart';
import 'dart:typed_data';

class BookCoverWidget extends StatelessWidget {
  final String? coverImagePath;
  final Uint8List? coverBytes;
  const BookCoverWidget({Key? key, this.coverImagePath, this.coverBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (coverBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(coverBytes!, width: 48, height: 64, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.menu_book, size: 32, color: Colors.grey[600]),
    );
  }
} 