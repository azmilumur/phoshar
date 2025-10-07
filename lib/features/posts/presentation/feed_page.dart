import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../controllers/feed_controller.dart';
import '../../../core/widgets/post_card.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollCtrl.position.pixels >=
        scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(feedControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);

    return feedState.when(
      loading: () => const AppLoading(),
      error: (err, _) => AppError(message: err.toString()),
      data: (posts) {
        if (posts.isEmpty) {
          return const AppEmptyState(
            message: 'Belum ada postingan dari yang kamu follow 😢',
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(feedControllerProvider.notifier).refreshFeed(),
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(post: post),
              );
            },
          ),
        );
      },
    );
  }
}
