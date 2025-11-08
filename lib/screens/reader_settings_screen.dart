import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';

class ReaderSettingsScreen extends StatefulWidget {
  final String bookId;
  const ReaderSettingsScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<ReaderSettingsScreen> createState() => _ReaderSettingsScreenState();
}

class _ReaderSettingsScreenState extends State<ReaderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final book = bookProvider.books.firstWhere((b) => b.id == widget.bookId);
    final isRightToLeft = book.isRightToLeft ?? false;
    final isVerticalScroll = book.isVerticalScroll ?? false;
    final reversePageOrder = book.reversePageOrder ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('Reader Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Reading Direction', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: Text('Right to Left'),
            subtitle: Text(isRightToLeft ? 'Reading from right to left' : 'Reading from left to right'),
            value: isRightToLeft,
            onChanged: (value) {
              final updated = Book(
                id: book.id,
                title: book.title,
                coverImagePath: book.coverImagePath,
                coverBytes: book.coverBytes,
                pages: book.pages,
                chapters: book.chapters,
                createdAt: book.createdAt,
                updatedAt: DateTime.now(),
                lastReadPageIndex: book.lastReadPageIndex,
                isRightToLeft: value,
                isVerticalScroll: book.isVerticalScroll,
                reversePageOrder: book.reversePageOrder,
              );
              bookProvider.updateBook(updated);
              setState(() {});
            },
          ),
          SizedBox(height: 24),
          Text('Scroll Direction', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: Text('Vertical Scrolling'),
            subtitle: Text(isVerticalScroll ? 'Vertical page scrolling' : 'Horizontal page scrolling'),
            value: isVerticalScroll,
            onChanged: (value) {
              final updated = Book(
                id: book.id,
                title: book.title,
                coverImagePath: book.coverImagePath,
                coverBytes: book.coverBytes,
                pages: book.pages,
                chapters: book.chapters,
                createdAt: book.createdAt,
                updatedAt: DateTime.now(),
                lastReadPageIndex: book.lastReadPageIndex,
                isRightToLeft: book.isRightToLeft,
                isVerticalScroll: value,
                reversePageOrder: book.reversePageOrder,
              );
              bookProvider.updateBook(updated);
              setState(() {});
            },
          ),
          SizedBox(height: 24),
          Text('Page Order', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: Text('Reverse Page Order'),
            subtitle: Text(reversePageOrder ? 'Reading from last page to first' : 'Reading from first page to last'),
            value: reversePageOrder,
            onChanged: (value) {
              final updated = Book(
                id: book.id,
                title: book.title,
                coverImagePath: book.coverImagePath,
                coverBytes: book.coverBytes,
                pages: book.pages,
                chapters: book.chapters,
                createdAt: book.createdAt,
                updatedAt: DateTime.now(),
                lastReadPageIndex: book.lastReadPageIndex,
                isRightToLeft: book.isRightToLeft,
                isVerticalScroll: book.isVerticalScroll,
                reversePageOrder: value,
              );
              bookProvider.updateBook(updated);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}


