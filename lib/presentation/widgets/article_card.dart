import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/article.dart';
import 'article_image.dart';
import 'auto_scroll_text.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, required this.onTap, super.key});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = article.publishedAt == null
        ? 'Date unavailable'
        : DateFormat('MMM d, yyyy').format(article.publishedAt!.toLocal());

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: article.imageUrl ?? '123',
                  child: ArticleImage(
                    width: MediaQuery.sizeOf(context).width,
                    imageUrl: article.imageUrl,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(color: Colors.white54),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.newsSite.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AutoScrollText(
                        text: article.title,
                        speed: 40,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),

                      // Text(article.authors.first.name ?? ""),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 10),
                      //   width: 10,
                      //   height: 10,
                      //   decoration: BoxDecoration(
                      //     color: Colors.grey,
                      //     shape: BoxShape.circle,
                      //   ),
                      // ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            date,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
