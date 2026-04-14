import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'package:korst/l10n/generated/app_localizations.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final UserProfileRepository _repository = sl<UserProfileRepository>();
  late Future<UserProfileEntity> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _repository.getOwnProfile();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _repository.getOwnProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context)!.myReviews)),
      body: FutureBuilder<UserProfileEntity>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${AppLocalizations.of(context)!.errorLoadingPrefix}${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return Center(child: Text(AppLocalizations.of(context)!.profileNotFound));
          }

          final reviews = profile.reviews;

          if (reviews.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 240),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(AppLocalizations.of(context)!.youHaveNoReviewsYet),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final authorFullName =
                    '${review.author.name} ${review.author.surname ?? ''}'
                        .trim();
                final name = authorFullName.isEmpty ? AppLocalizations.of(context)!.user : authorFullName;
                final photoUrl = review.author.photoUrl;

                return GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                                  ? CachedNetworkImageProvider(photoUrl)
                                  : null,
                              child: (photoUrl == null || photoUrl.isEmpty)
                                  ? Text(
                                      name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      ...List.generate(5, (starIndex) {
                                        IconData iconData;
                                        final double diff = review.rating - starIndex;
                                        if (diff >= 0.75) {
                                          iconData = Icons.star;
                                        } else if (diff >= 0.25) {
                                          iconData = Icons.star_half;
                                        } else {
                                          iconData = Icons.star_border;
                                        }
                                        return Icon(
                                          iconData,
                                          size: 14,
                                          color: Colors.amber,
                                        );
                                      }),
                                      const SizedBox(width: 6),
                                      Text(
                                        review.rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (review.comment.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            review.comment,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
