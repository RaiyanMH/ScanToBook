import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/page_model.dart';
import 'reader_screen.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../models/chapter.dart';
import 'chapter_detail_screen.dart';
import 'package:uuid/uuid.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;
  const BookDetailsScreen({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _reorderMode = false;
  
  void _createChapter(BuildContext context, Book book, int pageIndex) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Chapter'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Chapter name',
            labelText: 'Chapter Name',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text('Create')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final uuid = Uuid();
      final chapterId = uuid.v4();
      final newChapter = Chapter(
        id: chapterId,
        name: result.trim(),
        startPageIndex: pageIndex,
      );
      
      // Update all pages from this index onwards to belong to this chapter
      final updatedPages = book.pages.asMap().entries.map((entry) {
        if (entry.key >= pageIndex) {
          return PageModel(
            id: entry.value.id,
            imagePath: entry.value.imagePath,
            imageBytes: entry.value.imageBytes,
            isBookmarked: entry.value.isBookmarked,
            note: entry.value.note,
            chapterId: chapterId,
          );
        }
        return entry.value;
      }).toList();
      
      // Update previous chapter's endPageIndex if it exists
      final updatedChapters = List<Chapter>.from(book.chapters);
      if (updatedChapters.isNotEmpty) {
        final lastChapter = updatedChapters.last;
        updatedChapters[updatedChapters.length - 1] = Chapter(
          id: lastChapter.id,
          name: lastChapter.name,
          startPageIndex: lastChapter.startPageIndex,
          endPageIndex: pageIndex - 1,
        );
      }
      updatedChapters.add(newChapter);
      
      final updated = Book(
        id: book.id,
        title: book.title,
        coverImagePath: book.coverImagePath,
        coverBytes: book.coverBytes,
        pages: updatedPages,
        chapters: updatedChapters,
        createdAt: book.createdAt,
        updatedAt: DateTime.now(),
        lastReadPageIndex: book.lastReadPageIndex,
        isRightToLeft: book.isRightToLeft,
        isVerticalScroll: book.isVerticalScroll,
        reversePageOrder: book.reversePageOrder,
      );
      Provider.of<BookProvider>(context, listen: false).updateBook(updated);
      setState(() {});
    }
  }
  
  List<PageModel> _getBookmarkedPages(Book book) {
    return book.pages.where((p) => p.isBookmarked).toList();
  }
  void _renameBook(BuildContext context, Book book) async {
    final controller = TextEditingController(text: book.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename Book'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text('Rename')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final updated = Book(
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
      );
      Provider.of<BookProvider>(context, listen: false).updateBook(updated);
      setState(() {});
    }
  }

  void _setCover(BuildContext context, Book book) async {
    final idx = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Set Book Cover'),
        children: [
          ...book.pages.asMap().entries.map((entry) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, entry.key),
                child: Text('Page ${entry.key + 1}'),
              )),
        ],
      ),
    );
    if (idx != null) {
      final page = book.pages[idx];
      final updated = Book(
        id: book.id,
        title: book.title,
        coverImagePath: kIsWeb ? null : page.imagePath,
        coverBytes: page.imageBytes,
        pages: book.pages,
        chapters: book.chapters,
        createdAt: book.createdAt,
        updatedAt: DateTime.now(),
        lastReadPageIndex: book.lastReadPageIndex,
        isRightToLeft: book.isRightToLeft,
        isVerticalScroll: book.isVerticalScroll,
        reversePageOrder: book.reversePageOrder,
      );
      Provider.of<BookProvider>(context, listen: false).updateBook(updated);
      setState(() {});
    }
  }

  void _deleteBook(BuildContext context, Book book) async {
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
    if (confirm == true) {
      Provider.of<BookProvider>(context, listen: false).removeBook(book.id);
      Navigator.of(context).pop();
    }
  }

  void _addPage(BuildContext context, Book book) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      final newPage = PageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: kIsWeb ? picked.name : picked.path,
        imageBytes: kIsWeb ? await picked.readAsBytes() : null,
      );
      Provider.of<BookProvider>(context, listen: false).addPageToBook(book.id, newPage);
      setState(() {});
    }
  }

  Future<void> _exportAsPdf(BuildContext context, Book book) async {
    if (book.pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No pages to export')));
      return;
    }
    try {
      final pdf = pw.Document();
      for (final page in book.pages) {
        if (kIsWeb) {
          if (page.imageBytes != null) {
            final image = pw.MemoryImage(page.imageBytes!);
            pdf.addPage(pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
              },
            ));
          }
        } else {
          if (page.imagePath.isNotEmpty) {
            final file = File(page.imagePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final image = pw.MemoryImage(bytes);
              pdf.addPage(pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
                },
              ));
            }
          }
        }
      }
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF exported successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting PDF: $e')));
    }
  }

  void _deletePages(BuildContext context, Book book) async {
    final selected = await showDialog<List<int>>(
      context: context,
      builder: (ctx) {
        final selectedIndexes = <int>{};
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text('Delete Pages'),
            content: SizedBox(
              width: 300,
              height: 300,
              child: ListView(
                children: book.pages.asMap().entries.map((entry) {
                  return CheckboxListTile(
                    value: selectedIndexes.contains(entry.key),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        selectedIndexes.add(entry.key);
                      } else {
                        selectedIndexes.remove(entry.key);
                      }
                    }),
                    title: Text('Page ${entry.key + 1}'),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, selectedIndexes.toList()), child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
    );
    if (selected != null && selected.isNotEmpty) {
      for (final idx in selected.reversed) {
        Provider.of<BookProvider>(context, listen: false).removePageFromBook(book.id, book.pages[idx].id);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>().books;
    final Book? book = books.where((b) => b.id == widget.bookId).isNotEmpty ? books.firstWhere((b) => b.id == widget.bookId) : null;
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Book Not Found')),
        body: Center(child: Text('Book not found.')),
      );
    }
    final int total = book.pages.length;
    final int current = (book.lastReadPageIndex ?? -1) + 1; // 0-based -> 1-based; -1 means not started
    final double percent = total == 0 ? 0 : ((book.lastReadPageIndex ?? -1) + 1) / total;
    final header = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // cover
              Container(
                width: 96,
                height: 128,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[300]),
                clipBehavior: Clip.antiAlias,
                child: Builder(builder: (ctx) {
                  if (book.coverBytes != null) {
                    return Image.memory(book.coverBytes!, fit: BoxFit.cover);
                  } else if (book.coverImagePath != null && !kIsWeb) {
                    return Image.file(File(book.coverImagePath!), fit: BoxFit.cover);
                  }
                  return Icon(Icons.menu_book, size: 48, color: Colors.grey[600]);
                }),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chapters: ${book.chapters.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        total == 0
                            ? 'Progress: 0%'
                            : (current <= 0 ? 'Progress: 0%' : 'Progress: ${(percent * 100).toStringAsFixed(0)}%'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: total == 0
                            ? null
                            : () {
                                final startIndex = book.lastReadPageIndex != null ? book.lastReadPageIndex! : 0;
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ReaderScreen(bookId: book.id, initialIndex: startIndex)),
                                );
                              },
                        child: Text(current <= 0 ? 'Read' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'rearrange') {
                setState(() {
                  _reorderMode = !_reorderMode;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_reorderMode ? 'Drag pages to rearrange. Tap menu again to exit.' : 'Rearrange mode disabled')),
                );
              } else if (value == 'rename') {
                _renameBook(context, book);
              } else if (value == 'set_cover') {
                _setCover(context, book);
              } else if (value == 'delete') {
                _deleteBook(context, book);
              } else if (value == 'add_page') {
                _addPage(context, book);
              } else if (value == 'create_chapter') {
                final pageIndex = await showDialog<int>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Create Chapter'),
                    content: SizedBox(
                      width: 300,
                      height: 300,
                      child: ListView(
                        children: book.pages.asMap().entries.map((entry) {
                          return ListTile(
                            title: Text('Page ${entry.key + 1}'),
                            onTap: () => Navigator.pop(ctx, entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
                if (pageIndex != null) {
                  _createChapter(context, book, pageIndex);
                }
              } else if (value == 'delete_page') {
                _deletePages(context, book);
              } else if (value == 'export_pdf') {
                _exportAsPdf(context, book);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'set_cover', child: Text('Set Cover')),
              PopupMenuItem(value: 'add_page', child: Text('Add Page')),
              PopupMenuItem(value: 'create_chapter', child: Text('Create Chapter at Page...')),
              PopupMenuItem(value: 'rearrange', child: Text(_reorderMode ? 'Exit Rearrange' : 'Rearrange Pages')),
              PopupMenuItem(value: 'delete_page', child: Text('Delete Pages')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
              PopupMenuItem(value: 'export_pdf', child: Text('Export as PDF')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          header,
          // Bookmarks section
          if (_getBookmarkedPages(book).isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to bookmarks view
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Bookmarks'),
                          content: SizedBox(
                            width: 300,
                            height: 400,
                            child: ListView(
                              children: _getBookmarkedPages(book).map((page) {
                                final pageIndex = book.pages.indexWhere((p) => p.id == page.id);
                                return ListTile(
                                  leading: kIsWeb && page.imageBytes != null
                                      ? Image.memory(page.imageBytes!, width: 50, height: 50, fit: BoxFit.cover)
                                      : (!kIsWeb && page.imagePath.isNotEmpty
                                          ? Image.file(File(page.imagePath), width: 50, height: 50, fit: BoxFit.cover)
                                          : Icon(Icons.image)),
                                  title: Text('Page ${pageIndex + 1}'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => ReaderScreen(bookId: book.id, initialIndex: pageIndex)),
                                    );
                                  },
                                  trailing: IconButton(
                                    icon: Icon(Icons.bookmark, color: Colors.amber),
                                    onPressed: () {
                                      final updatedPage = PageModel(
                                        id: page.id,
                                        imagePath: page.imagePath,
                                        imageBytes: page.imageBytes,
                                        isBookmarked: false,
                                        note: page.note,
                                        chapterId: page.chapterId,
                                      );
                                      Provider.of<BookProvider>(context, listen: false).updatePageInBook(book.id, updatedPage);
                                      setState(() {});
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Close')),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.bookmark),
                    label: Text('Bookmarks (${_getBookmarkedPages(book).length})'),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          // Chapters section
          if (book.chapters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...book.chapters.map((chapter) {
                    final chapterPages = book.pages.where((p) => p.chapterId == chapter.id).length;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChapterDetailScreen(bookId: book.id, chapterId: chapter.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  chapter.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Text(
                                '$chapterPages pages',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
            child: book.pages.isEmpty
                ? Center(child: Text('No pages yet.'))
                : _reorderMode
                    ? ReorderableGridView.count(
                        padding: EdgeInsets.all(16),
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.7,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          final provider = Provider.of<BookProvider>(context, listen: false);
                          final pages = List<PageModel>.from(book.pages);
                          final item = pages.removeAt(oldIndex);
                          pages.insert(newIndex, item);
                          final updated = Book(
                            id: book.id,
                            title: book.title,
                            coverImagePath: book.coverImagePath,
                            coverBytes: book.coverBytes,
                            pages: pages,
                            chapters: book.chapters,
                            createdAt: book.createdAt,
                            updatedAt: DateTime.now(),
                            lastReadPageIndex: book.lastReadPageIndex,
                            isRightToLeft: book.isRightToLeft,
                            isVerticalScroll: book.isVerticalScroll,
                            reversePageOrder: book.reversePageOrder,
                          );
                          provider.updateBook(updated);
                          setState(() {});
                        },
                        children: List.generate(book.pages.length, (idx) {
                      final page = book.pages[idx];
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
                        key: ValueKey(page.id),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ReaderScreen(bookId: book.id, initialIndex: idx)),
                          );
                        },
                        onLongPress: () {
                          _createChapter(context, book, idx);
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
                    }),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: book.pages.length,
                        itemBuilder: (context, idx) {
                          final page = book.pages[idx];
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
                                MaterialPageRoute(builder: (_) => ReaderScreen(bookId: book.id, initialIndex: idx)),
                              );
                            },
                            onLongPress: () {
                              _createChapter(context, book, idx);
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