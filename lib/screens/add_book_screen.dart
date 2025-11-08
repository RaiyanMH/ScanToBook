import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/page_model.dart';
import '../providers/book_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddBookScreen extends StatefulWidget {
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final List<dynamic> _scannedImages = [];
  final List<Uint8List?> _scannedBytes = [];
  final _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _scannedImages.add(picked);
          _scannedBytes.add(bytes);
        });
      } else {
        setState(() {
          _scannedImages.add(File(picked.path));
          _scannedBytes.add(null);
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _scannedImages.removeAt(index);
      _scannedBytes.removeAt(index);
    });
  }

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage(imageQuality: 90);
    if (pickedList.isNotEmpty) {
      if (kIsWeb) {
        for (final xf in pickedList) {
          final bytes = await xf.readAsBytes();
          _scannedImages.add(xf);
          _scannedBytes.add(bytes);
        }
      } else {
        for (final xf in pickedList) {
          _scannedImages.add(File(xf.path));
          _scannedBytes.add(null);
        }
      }
      setState(() {});
    }
  }

  Future<void> _continuousCapture() async {
    // Simple looped camera capture; user can cancel by closing camera
    bool keepCapturing = true;
    final picker = ImagePicker();
    while (keepCapturing) {
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (picked == null) break;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        _scannedImages.add(picked);
        _scannedBytes.add(bytes);
      } else {
        _scannedImages.add(File(picked.path));
        _scannedBytes.add(null);
      }
      setState(() {});
      // Optionally prompt to continue
      final cont = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Add another page?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Done')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Add')),
          ],
        ),
      );
      keepCapturing = cont == true;
    }
  }

  Future<void> _saveBook() async {
    if (_titleController.text.trim().isEmpty || _scannedImages.isEmpty) return;
    setState(() => _isSaving = true);
    final uuid = Uuid();
    final bookId = uuid.v4();
    final now = DateTime.now();
    final pages = <PageModel>[];
    for (int i = 0; i < _scannedImages.length; i++) {
      final img = _scannedImages[i];
      String path = '';
      Uint8List? bytes;
      if (kIsWeb) {
        final xf = img as XFile;
        path = xf.name;
        bytes = _scannedBytes[i];
      } else {
        path = (img as File).path;
      }
      pages.add(PageModel(id: uuid.v4(), imagePath: path, imageBytes: bytes));
    }
    final book = Book(
      id: bookId,
      title: _titleController.text.trim(),
      coverImagePath: kIsWeb ? null : (_scannedImages.first as File).path,
      coverBytes: kIsWeb ? _scannedBytes.first : null,
      pages: pages,
      createdAt: now,
      updatedAt: now,
      lastReadPageIndex: null,
      isRightToLeft: false,
      isVerticalScroll: false,
      reversePageOrder: false,
    );
    Provider.of<BookProvider>(context, listen: false).addBook(book);
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Book Title',
                labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.8)),
                hintText: 'Enter a title',
                hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: scheme.surface,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Scan Page'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library),
                  label: Text('Pick from Gallery'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.collections),
                  label: Text('Multi-select'),
                  onPressed: _pickMultipleImages,
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text('Continuous'),
                  onPressed: _continuousCapture,
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _scannedImages.isEmpty
                  ? Center(child: Text('No pages scanned yet.'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _scannedImages.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12),
                      itemBuilder: (context, idx) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.memory(
                                    _scannedBytes[idx]!,
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _scannedImages[idx],
                                    width: 120,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () => _removeImage(idx),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _scannedImages.isEmpty
                      ? null
                      : () {
                          final img = _scannedImages.removeAt(0);
                          final bytes = _scannedBytes.removeAt(0);
                          _scannedImages.insert(0, img);
                          _scannedBytes.insert(0, bytes);
                          setState(() {});
                        },
                  child: Text('Use first image as Cover'),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving || _titleController.text.trim().isEmpty || _scannedImages.isEmpty ? null : _saveBook,
                child: _isSaving ? CircularProgressIndicator() : Text('Save Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 