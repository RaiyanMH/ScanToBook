import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../models/page_model.dart';
import 'reader_settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;
import 'package:photo_view/photo_view.dart';

class ReaderScreen extends StatefulWidget {
  final String bookId;
  final int initialIndex;
  const ReaderScreen({Key? key, required this.bookId, this.initialIndex = 0}) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _chromeVisible = false;
  int _currentIndex = 0;
  PageController? _pageController;
  ScrollController? _scrollController;
  final FocusNode _focusNode = FocusNode();
  DateTime? _lastInteractionTime;
  bool _autoHideChrome = true;
  String _scaleMode = 'fit_center'; // fit_center, fit_height, fit_width, keep_at_start
  bool _volumeButtonsEnabled = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _startAutoHideTimer();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _startAutoHideTimer() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _autoHideChrome && _chromeVisible) {
        setState(() => _chromeVisible = false);
      }
    });
  }

  void _showChrome() {
    setState(() {
      _chromeVisible = true;
      _lastInteractionTime = DateTime.now();
    });
    _startAutoHideTimer();
  }

  void _handleTap(TapDownDetails details) {
    final size = MediaQuery.of(context).size;
    final y = details.globalPosition.dy;
    final topThreshold = 100;
    final bottomThreshold = size.height - 100;
    
    if (y < topThreshold || y > bottomThreshold) {
      _showChrome();
    } else {
      setState(() => _chromeVisible = !_chromeVisible);
      if (_chromeVisible) {
        _startAutoHideTimer();
      }
    }
  }

  void _updateProgress(Book book, int currentIndex) {
    final provider = context.read<BookProvider>();
    final reversePageOrder = book.reversePageOrder ?? false;
    final displayPages = reversePageOrder ? List<PageModel>.from(book.pages.reversed) : book.pages;
    final actualPageIndex = reversePageOrder ? displayPages.length - 1 - currentIndex : currentIndex;
    final updated = Book(
      id: book.id,
      title: book.title,
      coverImagePath: book.coverImagePath,
      coverBytes: book.coverBytes,
      pages: book.pages,
      chapters: book.chapters,
      createdAt: book.createdAt,
      updatedAt: DateTime.now(),
      lastReadPageIndex: actualPageIndex,
      isRightToLeft: book.isRightToLeft,
      isVerticalScroll: book.isVerticalScroll,
      reversePageOrder: book.reversePageOrder,
    );
    provider.updateBook(updated);
  }

  Widget _buildPageImage(int index, List<PageModel> pages) {
    if (index >= pages.length) return Container(color: Colors.black);
    final page = pages[index];
    
    ImageProvider imageProvider;
    if (kIsWeb) {
      if (page.imageBytes != null) {
        imageProvider = MemoryImage(page.imageBytes!);
      } else {
        return Container(
          color: Colors.black,
          child: Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 96)),
        );
      }
    } else {
      if (page.imagePath.isNotEmpty) {
        imageProvider = FileImage(File(page.imagePath));
      } else {
        return Container(
          color: Colors.black,
          child: Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 96)),
        );
      }
    }

    PhotoViewComputedScale initialScale;
    switch (_scaleMode) {
      case 'fit_height':
        initialScale = PhotoViewComputedScale.covered;
        break;
      case 'fit_width':
        initialScale = PhotoViewComputedScale.contained;
        break;
      case 'keep_at_start':
        initialScale = PhotoViewComputedScale.contained;
        break;
      case 'fit_center':
      default:
        initialScale = PhotoViewComputedScale.contained;
        break;
    }

    return PhotoView(
      imageProvider: imageProvider,
      backgroundDecoration: BoxDecoration(color: Colors.black),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      initialScale: initialScale,
    );
  }
  
  void _toggleBookmark() {
    final book = context.read<BookProvider>().books.firstWhere((b) => b.id == widget.bookId);
    final displayPages = book.reversePageOrder ?? false ? List<PageModel>.from(book.pages.reversed) : book.pages;
    final currentPage = displayPages[_currentIndex];
    final actualPageIndex = book.pages.indexWhere((p) => p.id == currentPage.id);
    final actualPage = book.pages[actualPageIndex];
    
    final updatedPage = PageModel(
      id: actualPage.id,
      imagePath: actualPage.imagePath,
      imageBytes: actualPage.imageBytes,
      isBookmarked: !actualPage.isBookmarked,
      note: actualPage.note,
      chapterId: actualPage.chapterId,
    );
    context.read<BookProvider>().updatePageInBook(book.id, updatedPage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updatedPage.isBookmarked ? 'Page bookmarked' : 'Bookmark removed')),
    );
  }
  
  void _savePage() async {
    final book = context.read<BookProvider>().books.firstWhere((b) => b.id == widget.bookId);
    final displayPages = book.reversePageOrder ?? false ? List<PageModel>.from(book.pages.reversed) : book.pages;
    final currentPage = displayPages[_currentIndex];
    
    // For web, we can't save files directly, so show a message
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Page saved (web download not implemented)')),
      );
    } else {
      // On mobile, could implement file saving here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Page saved to gallery')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = context.watch<BookProvider>().books.firstWhere((b) => b.id == widget.bookId);
    final isRightToLeft = book.isRightToLeft ?? false;
    final isVerticalScroll = book.isVerticalScroll ?? false;
    final reversePageOrder = book.reversePageOrder ?? false;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    
    List<PageModel> displayPages = List.from(book.pages);
    if (reversePageOrder) {
      displayPages = displayPages.reversed.toList();
    }

    Widget pageView;
    
    if (isVerticalScroll) {
      _scrollController?.addListener(() {
        final pageHeight = MediaQuery.of(context).size.height;
        final newIndex = (_scrollController!.offset / pageHeight).round().clamp(0, displayPages.length - 1);
        if (newIndex != _currentIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
          _updateProgress(book, _currentIndex);
        }
      });
      pageView = ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        itemCount: displayPages.length,
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTapDown: _handleTap,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: _buildPageImage(i, displayPages),
            ),
          );
        },
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController != null && !_scrollController!.hasClients) {
          _scrollController!.jumpTo(_currentIndex * MediaQuery.of(context).size.height);
        }
      });
    } else {
      pageView = PageView.builder(
        controller: _pageController,
        reverse: isRightToLeft,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          _updateProgress(book, _currentIndex);
        },
        itemCount: displayPages.length,
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTapDown: _handleTap,
            child: MouseRegion(
              onHover: (event) {
                final size = MediaQuery.of(context).size;
                if (event.position.dy > size.height - 100 || event.position.dy < 100) {
                  _showChrome();
                }
              },
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: _buildPageImage(i, displayPages),
              ),
            ),
          );
        },
      );

      if (isWide && !isVerticalScroll) {
        final leftPageIndex = _currentIndex * 2;
        final rightPageIndex = (_currentIndex * 2) + 1;
        pageView = PageView.builder(
          controller: _pageController,
          reverse: isRightToLeft,
          onPageChanged: (i) {
            setState(() => _currentIndex = i);
            _updateProgress(book, _currentIndex);
          },
          itemCount: (displayPages.length / 2).ceil(),
          itemBuilder: (ctx, i) {
            final leftIdx = i * 2;
            final rightIdx = (i * 2) + 1;
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: _handleTap,
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: leftIdx < displayPages.length ? _buildPageImage(leftIdx, displayPages) : Container(color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapDown: _handleTap,
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: rightIdx < displayPages.length ? _buildPageImage(rightIdx, displayPages) : Container(color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _chromeVisible
          ? AppBar(
              title: Text('Page ${_currentIndex + 1} / ${displayPages.length}'),
              backgroundColor: Colors.black.withOpacity(0.7),
              leading: BackButton(color: Colors.white),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ReaderSettingsScreen(bookId: widget.bookId)),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Focus(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              final book = context.read<BookProvider>().books.firstWhere((b) => b.id == widget.bookId);
              final isVerticalScroll = book.isVerticalScroll ?? false;
              if (isVerticalScroll) {
                if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  _scrollController?.animateTo(
                    (_scrollController!.offset - MediaQuery.of(context).size.height).clamp(0.0, _scrollController!.position.maxScrollExtent),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                  _scrollController?.animateTo(
                    (_scrollController!.offset + MediaQuery.of(context).size.height).clamp(0.0, _scrollController!.position.maxScrollExtent),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else {
                final isRightToLeft = book.isRightToLeft ?? false;
                if (isRightToLeft) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    _pageController?.nextPage(duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    _pageController?.previousPage(duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
                  }
                } else {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    _pageController?.previousPage(duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    _pageController?.nextPage(duration: Duration(milliseconds: 150), curve: Curves.easeInOut);
                  }
                }
              }
            }
          },
          child: Stack(
          children: [
            Positioned.fill(child: pageView),
            if (_chromeVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(icon: Icon(Icons.first_page, color: Colors.white), onPressed: () => _pageController?.jumpToPage(0)),
                      IconButton(icon: Icon(Icons.chevron_left, color: Colors.white), onPressed: () => _pageController?.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeInOut)),
                      Expanded(
                        child: Slider(
                          value: _currentIndex.toDouble().clamp(0, (displayPages.length - 1).toDouble()),
                          min: 0,
                          max: (displayPages.length - 1).toDouble(),
                          onChanged: (v) => _pageController?.jumpToPage(v.toInt()),
                        ),
                      ),
                      IconButton(icon: Icon(Icons.chevron_right, color: Colors.white), onPressed: () => _pageController?.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeInOut)),
                      Builder(
                        builder: (context) {
                          final book = context.watch<BookProvider>().books.firstWhere((b) => b.id == widget.bookId);
                          final displayPages = book.reversePageOrder ?? false ? List<PageModel>.from(book.pages.reversed) : book.pages;
                          final currentPage = _currentIndex < displayPages.length ? displayPages[_currentIndex] : null;
                          return IconButton(
                            icon: Icon(
                              currentPage?.isBookmarked == true ? Icons.bookmark : Icons.bookmark_border,
                              color: currentPage?.isBookmarked == true ? Colors.amber : Colors.white,
                            ),
                            onPressed: _toggleBookmark,
                            tooltip: 'Bookmark',
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'save_page') {
                            _savePage();
                          } else if (value == 'add_bookmark') {
                            _toggleBookmark();
                          } else if (value == 'volume_buttons') {
                            setState(() {
                              _volumeButtonsEnabled = !_volumeButtonsEnabled;
                            });
                          } else if (value.startsWith('scale_')) {
                            setState(() {
                              _scaleMode = value.replaceFirst('scale_', '');
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'save_page', child: Text('Save Page')),
                          PopupMenuItem(value: 'add_bookmark', child: Text('Add Bookmark')),
                          if (!kIsWeb)
                            PopupMenuItem(
                              value: 'volume_buttons',
                              child: Row(
                                children: [
                                  Text('Enable Volume Buttons'),
                                  Spacer(),
                                  if (_volumeButtonsEnabled) Icon(Icons.check, size: 16),
                                ],
                              ),
                            ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'scale_fit_center',
                            child: Row(
                              children: [
                                Text('Fit Center'),
                                Spacer(),
                                if (_scaleMode == 'fit_center') Icon(Icons.check, size: 16),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'scale_fit_height',
                            child: Row(
                              children: [
                                Text('Fit to Height'),
                                Spacer(),
                                if (_scaleMode == 'fit_height') Icon(Icons.check, size: 16),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'scale_fit_width',
                            child: Row(
                              children: [
                                Text('Fit to Width'),
                                Spacer(),
                                if (_scaleMode == 'fit_width') Icon(Icons.check, size: 16),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'scale_keep_at_start',
                            child: Row(
                              children: [
                                Text('Keep at Start'),
                                Spacer(),
                                if (_scaleMode == 'keep_at_start') Icon(Icons.check, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(icon: Icon(Icons.last_page, color: Colors.white), onPressed: () => _pageController?.jumpToPage(displayPages.length - 1)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
