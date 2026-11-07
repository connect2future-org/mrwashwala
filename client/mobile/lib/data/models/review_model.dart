class ReviewModel {
  final String id;
  final String author;
  final int rating;
  final String text;
  final String? orderId;
  final DateTime? reviewDate;
  final String? branchName;
  final bool approved;

  ReviewModel({
    required this.id,
    required this.author,
    required this.rating,
    required this.text,
    this.orderId,
    this.reviewDate,
    this.branchName,
    this.approved = true,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'] as String? ?? '';
    String? extractedOrderId;
    final match = RegExp(r'\[Order (MRW-[A-Za-z0-9]+)\]').firstMatch(rawText);
    if (match != null) {
      extractedOrderId = match.group(1);
    }

    String? branchName;
    if (json['branch'] != null && json['branch']['name'] != null) {
      branchName = json['branch']['name'].toString();
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      author: json['author'] ?? 'Valued Customer',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      text: rawText,
      orderId: extractedOrderId,
      reviewDate: json['reviewDate'] != null
          ? DateTime.tryParse(json['reviewDate'].toString())
          : null,
      branchName: branchName,
      approved: json['approved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'author': author,
      'rating': rating,
      'text': text,
      'approved': approved,
    };
  }

  /// Clean display text without internal order tags
  String get displayText {
    return text.replaceAll(RegExp(r'\[Order MRW-[A-Za-z0-9]+\]\s*'), '').trim();
  }

  String get formattedDate {
    if (reviewDate == null) return 'Recently';
    return '${reviewDate!.day}/${reviewDate!.month}/${reviewDate!.year}';
  }
}
