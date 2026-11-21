class Article {
  const Article({
    required this.id,
    required this.title,
    required this.url,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    this.imageUrl,
    required this.authors,
  });

  final int id;
  final String title;
  final String url;
  final String newsSite;
  final String summary;
  final DateTime? publishedAt;
  final String? imageUrl;
  final List<Author> authors;

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: _toInt(json['id']),
      title: _toString(json['title'], fallback: 'Untitled article'),
      url: _toString(json['url']),
      newsSite: _toString(json['news_site'], fallback: 'Unknown source'),
      summary: _toString(json['summary'], fallback: 'No summary available.'),
      publishedAt: DateTime.tryParse(_toString(json['published_at'])),
      imageUrl: _nullableString(json['image_url']),
      authors: json['authors'] != null && json['authors'] is List
          ? List.from(json['authors'].map((it) => Author.fromJson(it)))
          : [],
    );
  }

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;

  static String _toString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value.toString().trim();
    return result.isEmpty ? fallback : result;
  }

  static String? _nullableString(dynamic value) {
    final result = value?.toString().trim();
    if (result == null || result.isEmpty) return null;
    return result;
  }
}

class AuthorResponse {
  final List<Author> authors;

  AuthorResponse({required this.authors});

  factory AuthorResponse.fromJson(Map<String, dynamic> json) {
    return AuthorResponse(
      authors:
          (json['authors'] as List<dynamic>?)
              ?.map((e) => Author.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'authors': authors.map((e) => e.toJson()).toList()};
  }
}

class Author {
  final String? name;
  final dynamic socials;

  Author({this.name, this.socials});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(name: json['name'] as String?, socials: json['socials']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'socials': socials};
  }
}
