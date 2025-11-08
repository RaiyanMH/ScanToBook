import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../providers/book_provider.dart';
import '../models/page_model.dart';
import 'reader_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class ChapterDetailScreen extends StatelessWidget {
  final String bookId;
  final String chapterId;
  const ChapterDetailScreen({Key? key, required this.bookId, required this.chapterId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final book = context.watch<BookProvider>().books.firstWhere((b) => b.id == bookId);
    final chapter = book.chapters.firstWhere((c) => c.id == chapterId);
    final chapterPages = book.pages.where((p) => p.chapterId == chapterId).toList();
    final startIndex = book.pages.indexWhere((p) => p.chapterId == chapterId);
    int lastReadPageInChapter = -1;
    if (book.lastReadPageIndex != null && book.lastReadPageIndex! < book.pages.length) {
      final lastReadPage = book.pages[book.lastReadPageIndex!];
      lastReadPageInChapter = chapterPages.indexWhere((p) => p.id == lastReadPage.id);
    }
    final hasProgress = book.lastReadPageIndex != null && lastReadPageInChapter >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${chapterPages.length} pages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: chapterPages.isEmpty
                        ? null
                        : () {
                            final initialIndex = hasProgress ? startIndex + lastReadPageInChapter : startIndex;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(bookId: bookId, initialIndex: initialIndex),
                              ),
                            );
                          },
                    child: Text(hasProgress ? 'Continue' : 'Start Reading'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: chapterPages.isEmpty
                ? Center(child: Text('No pages in this chapter.'))
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: chapterPages.length,
                    itemBuilder: (context, idx) {
                      final page = chapterPages[idx];
                      final globalIndex = book.pages.indexWhere((p) => p.id == page.id);
                      Widget thumbnail;
                      if (kIsWeb) {
                        if (page.imageBytes != null) {
                          thumbnail = Image.memory(page.imageBytes!, fit: BoxFit.cover);
                        } else {
                          thumbnail = Container(
                            color: Colors.grey[200],
                            child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400])),
                          );
                        }
                      } else {
                        if (page.imagePath.isNotEmpty) {
                          thumbnail = Image.file(File(page.imagePath), fit: BoxFit.cover);
                        } else {
                          thumbnail = Container(
                            color: Colors.grey[200],
                            child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey[400])),
                          );
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ReaderScreen(bookId: bookId, initialIndex: globalIndex)),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: thumbnail,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

