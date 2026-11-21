import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/article.dart';
import '../viewmodels/news_view_model.dart';
import '../widgets/article_image.dart';
import '../widgets/status_views.dart';

class NewsDetailScreen extends StatefulWidget {
  const NewsDetailScreen({required this.initialIndex, super.key});
  final int initialIndex;

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsViewModel>();
    if (vm.articles.isEmpty || _currentIndex >= vm.articles.length) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} of ${vm.articles.length}'),
        actions: [
          IconButton(
            tooltip: 'Previous article',
            onPressed: _currentIndex > 0 ? _previous : null,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next article',
            onPressed: _currentIndex < vm.articles.length - 1 ? _next : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: vm.articles.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          if (index >= vm.articles.length - 2 && vm.hasMore) {
            vm.loadMore();
          }
        },
        itemBuilder: (context, index) {
          return _DetailContent(article: vm.articles[index]);
        },
      ),
    );
  }

  void _previous() => _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

  void _next() {
    final vm = context.read<NewsViewModel>();
    if (_currentIndex == vm.articles.length - 1 && vm.hasMore) {
      vm.loadMore();
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final date = article.publishedAt == null
        ? 'Date unavailable'
        : DateFormat('MMMM d, yyyy • h:mm a')
            .format(article.publishedAt!.toLocal());

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final imageHeight = wide ? 400.0 : constraints.maxHeight * 0.40;

        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 32 : 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: article.imageUrl??'123',
                      child: ArticleImage(
                        imageUrl: article.imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        borderRadius: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      article.newsSite.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      style: (wide
                              ? Theme.of(context).textTheme.headlineMedium
                              : Theme.of(context).textTheme.headlineSmall)
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16),
                        const SizedBox(width: 6),
                        Text(date),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      article.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                          ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: wide ? null : double.infinity,
                      child: FilledButton.icon(
                        onPressed: article.url.isEmpty
                            ? null
                            : () => _openArticle(article.url),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Read full article'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openArticle(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // The UI remains usable if the external browser cannot be opened.
    }
  }
}
