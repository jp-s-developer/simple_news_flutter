import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/article.dart';
import '../../data/repositories/news_repository.dart';

class NewsViewModel extends ChangeNotifier {
  NewsViewModel(this._repository);

  final NewsRepository _repository;
  final List<Article> _articles = [];
  Timer? _searchTimer;
  String _search = '';
  int? _nextOffset;
  String? _error;
  String? _paginationError;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoaded = false;
  int _requestGeneration = 0;

  List<Article> get articles => List.unmodifiable(_articles);
  String get search => _search;
  String? get error => _error;
  String? get paginationError => _paginationError;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasLoaded => _hasLoaded;
  bool get hasMore => _nextOffset != null;

  Future<void> loadInitial() async {
    await _loadFirstPage();
  }

  Future<void> refresh() async {
    await _loadFirstPage();
  }

  void updateSearch(String value) {
    _search = value;
    _searchTimer?.cancel();
    _searchTimer = Timer(AppConstants.searchDebounce, _loadFirstPage);
    notifyListeners();
  }

  Future<void> submitSearch() async {
    _searchTimer?.cancel();
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_requestGeneration;
    _isLoading = true;
    _error = null;
    _paginationError = null;
    _nextOffset = null;
    _articles.clear();
    _hasLoaded = false;
    notifyListeners();

    try {
      final page = await _repository.fetchArticles(search: _search);
      if (generation != _requestGeneration) return;
      _articles
        ..clear()
        ..addAll(page.articles);
      _nextOffset = page.nextOffset;
      _hasLoaded = true;
    } on ApiException catch (error) {
      if (generation == _requestGeneration) _error = error.message;
    } catch (_) {
      if (generation == _requestGeneration) {
        _error = 'Unable to load news. Please try again.';
      }
    } finally {
      if (generation == _requestGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final offset = _nextOffset;
      if (offset == null) return;
      final page = await _repository.fetchArticles(
        offset: offset,
        search: _search,
      );
      final existingIds = _articles.map((article) => article.id).toSet();
      final unique = page.articles
          .where((article) => !existingIds.contains(article.id));
      _articles.addAll(unique);
      _nextOffset = page.nextOffset;
    } on ApiException catch (error) {
      _paginationError = error.message;
    } catch (_) {
      _paginationError = 'Could not load more articles.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
