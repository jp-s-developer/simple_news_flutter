import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/article.dart';

class NewsPage {
  const NewsPage({required this.articles, required this.nextOffset});
  final List<Article> articles;
  final int? nextOffset;
}

class NewsRepository {
  NewsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<NewsPage> fetchArticles({
    int offset = 0,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'limit': AppConstants.pageSize,
      'offset': offset,
      'ordering': '-published_at',
    };
    final term = search?.trim();
    if (term != null && term.isNotEmpty) {
      // SNAPI's `search` filter searches both title and summary.
      query['search'] = term;
    }

    final json = await _apiClient.get('/articles/', queryParameters: query);
    final rawResults = json['results'];
    final articles = rawResults is List
        ? rawResults
            .whereType<Map<String, dynamic>>()
            .map(Article.fromJson)
            .toList(growable: false)
        : <Article>[];

    final next = json['next']?.toString();
    final nextOffset = next == null
        ? null
        : int.tryParse(Uri.tryParse(next)?.queryParameters['offset'] ?? '');

    return NewsPage(articles: articles, nextOffset: nextOffset);
  }

  Future<Article> fetchArticle(int id) async {
    final json = await _apiClient.get('/articles/$id/');
    return Article.fromJson(json);
  }
}
