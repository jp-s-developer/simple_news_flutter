import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../viewmodels/news_view_model.dart';
import '../widgets/article_card.dart';
import '../widgets/status_views.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;
  Timer? _scrollTimer;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 500) {
      context.read<NewsViewModel>().loadMore();
    }

    if (_showHeader) {
      setState(() => _showHeader = false);
    }
    _scrollTimer?.cancel();

    _scrollTimer = Timer(
      const Duration(milliseconds: 500),
          () {
        if (mounted) {
          setState(() => _showHeader = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            SystemNavigator.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,size: 20,),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: vm.isLoading ? null : vm.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
        AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: _showHeader
            ?    Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 30),
                  ),
                  Text('News from all around the world'),
                  const SizedBox(height: 20,),
                  TextField(
                    onChanged: vm.updateSearch,
                    onSubmitted: (_) => vm.submitSearch(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search news by title or summary',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: vm.search.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                vm.updateSearch('');
                                vm.submitSearch();
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ): const SizedBox.shrink()),
            Expanded(child: _buildBody(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NewsViewModel vm) {
    if (vm.isLoading && vm.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.articles.isEmpty) {
      return ErrorView(message: vm.error!, onRetry: vm.refresh);
    }
    if (vm.articles.isEmpty && vm.hasLoaded) {
      return const EmptyView(message: 'No news articles match your search.');
    }

    return RefreshIndicator(
      onRefresh: vm.refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1100
              ? 3
              : width >= 650
              ? 2
              : 1;
          final horizontalPadding = width >= 650 ? 24.0 : 16.0;

          return GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              4,
              horizontalPadding,
              24,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 1.5 : 1.3,
            ),
            itemCount:
                vm.articles.length + (vm.hasMore || vm.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= vm.articles.length) {
                if (vm.paginationError != null) {
                  return Center(
                    child: TextButton.icon(
                      onPressed: vm.loadMore,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry loading more'),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }
              final article = vm.articles[index];
              return ArticleCard(
                article: article,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewsDetailScreen(initialIndex: index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
