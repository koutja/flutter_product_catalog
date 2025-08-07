class PagingList<T extends Object> {
  const PagingList({
    required this.first,
    required this.prev,
    required this.next,
    required this.last,
    required this.pages,
    required this.items,
    required this.data,
  });

  final int first;
  final int? prev;
  final int? next;
  final int last;
  final int pages;
  final int items;
  final Iterable<T> data;

  bool get isEmpty => data.isEmpty;
}
