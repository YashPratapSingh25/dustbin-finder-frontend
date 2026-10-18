class PaginationMetadata {
  final bool hasNext;
  final bool hasPrevious;
  final int pageNumber;
  final int totalPages;
  final int pageSize;
  final int totalItems;

  const PaginationMetadata({
    required this.hasNext,
    required this.hasPrevious,
    required this.pageNumber,
    required this.totalPages,
    required this.pageSize,
    required this.totalItems,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
      pageNumber: (json['page_number'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 10,
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
    );
  }
}