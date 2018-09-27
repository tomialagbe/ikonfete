class Page<T> {
  final List<T> items;
  final int pageSize;

  Page.from({
    this.items,
    this.pageSize,
  });

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
