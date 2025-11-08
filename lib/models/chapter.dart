class Chapter {
  final String id;
  final String name;
  final int startPageIndex; // Index of the first page in this chapter
  int? endPageIndex; // Index of the last page (null if it's the last chapter)

  Chapter({
    required this.id,
    required this.name,
    required this.startPageIndex,
    this.endPageIndex,
  });
}

