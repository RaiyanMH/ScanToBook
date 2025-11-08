import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/page_model.dart';

class BookProvider extends ChangeNotifier {
  final List<Book> _books = [];

  List<Book> get books => _books;

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void removeBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void updateBook(Book updatedBook) {
    final idx = _books.indexWhere((b) => b.id == updatedBook.id);
    if (idx != -1) {
      _books[idx] = updatedBook;
      notifyListeners();
    }
  }

  void addPageToBook(String bookId, PageModel page) {
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => throw Exception('Book not found'));
    book.pages.add(page);
    book.updatedAt = DateTime.now();
    notifyListeners();
  }

  void removePageFromBook(String bookId, String pageId) {
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => throw Exception('Book not found'));
    book.pages.removeWhere((p) => p.id == pageId);
    book.updatedAt = DateTime.now();
    notifyListeners();
  }

  void updatePageInBook(String bookId, PageModel updatedPage) {
    final book = _books.firstWhere((b) => b.id == bookId, orElse: () => throw Exception('Book not found'));
    final idx = book.pages.indexWhere((p) => p.id == updatedPage.id);
    if (idx != -1) {
      book.pages[idx] = updatedPage;
      book.updatedAt = DateTime.now();
      notifyListeners();
    }
  }
} 