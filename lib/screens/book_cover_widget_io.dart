import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

class BookCoverWidget extends StatelessWidget {
  final String? coverImagePath;
  final Uint8List? coverBytes;
  const BookCoverWidget({Key? key, this.coverImagePath, this.coverBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (coverImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: FileImage(File(coverImagePath!)),
          width: 48,
          height: 64,
          fit: BoxFit.cover,
        ),
      );
    } else {
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
} 