import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'add_book_screen.dart';
import 'package:flutter/foundation.dart';
import 'book_cover_widget.dart';
import 'book_details_screen.dart';
import 'settings_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class BooksListScreen extends StatefulWidget {
  const BooksListScreen({Key? key}) : super(key: key);

  @override
  State<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends State<BooksListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>().books.where((b) => b.title.toLowerCase().contains(_search.toLowerCase())).toList();
    final crossAxisCount = MediaQuery.of(context).size.width ~/ 180; // approx card width
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Books', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          Expanded(
            child: books.isEmpty
                ? Center(
                    child: Text('No books found.', style: Theme.of(context).textTheme.titleMedium),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount.clamp(1, 6),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.66,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, idx) {
                      final book = books[idx];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: BookCoverWidget(
                                  coverImagePath: book.coverImagePath,
                                  coverBytes: book.coverBytes,
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    book.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'rename') {
                                      final controller = TextEditingController(text: book.title);
                                      final result = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Rename Book'),
                                          content: TextField(controller: controller),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text('Rename')),
                                          ],
                                        ),
                                      );
                                      if (result != null && result.trim().isNotEmpty) {
                                        context.read<BookProvider>().updateBook(Book(
                                          id: book.id,
                                          title: result.trim(),
                                          coverImagePath: book.coverImagePath,
                                          coverBytes: book.coverBytes,
                                          pages: book.pages,
                                          chapters: book.chapters,
                                          createdAt: book.createdAt,
                                          updatedAt: DateTime.now(),
                                          lastReadPageIndex: book.lastReadPageIndex,
                                          isRightToLeft: book.isRightToLeft,
                                          isVerticalScroll: book.isVerticalScroll,
                                          reversePageOrder: book.reversePageOrder,
                                        ));
                                      }
                                    } else if (value == 'set_cover') {
                                      final picker = ImagePicker();
                                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                                      if (picked != null) {
                                        final bytes = kIsWeb ? await picked.readAsBytes() : null;
                                        final updated = Book(
                                          id: book.id,
                                          title: book.title,
                                          coverImagePath: kIsWeb ? null : picked.path,
                                          coverBytes: bytes,
                                          pages: book.pages,
                                          chapters: book.chapters,
                                          createdAt: book.createdAt,
                                          updatedAt: DateTime.now(),
                                          lastReadPageIndex: book.lastReadPageIndex,
                                          isRightToLeft: book.isRightToLeft,
                                          isVerticalScroll: book.isVerticalScroll,
                                          reversePageOrder: book.reversePageOrder,
                                        );
                                        context.read<BookProvider>().updateBook(updated);
                                      }
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Delete Book'),
                                          content: Text('Are you sure you want to delete this book?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) context.read<BookProvider>().removeBook(book.id);
                                    } else if (value == 'export_pdf') {
                                      // Export PDF handled in book_details_screen
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                                    PopupMenuItem(value: 'set_cover', child: Text('Set Cover (Upload)')),
                                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    PopupMenuItem(value: 'export_pdf', child: Text('Export as PDF')),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddBookScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Book',
      ),
    );
  }
} 