import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/explore_controller.dart';
import 'widgets/post_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollCtrl.addListener(() {
      if (scrollCtrl.position.pixels >=
          scrollCtrl.position.maxScrollExtent - 200) {
        // udah di bawah → ambil halaman berikutnya
        ref.read(exploreControllerProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: state.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(message: e.toString()),
        data: (posts) {
          if (posts.isEmpty) {
            return const AppEmptyState(message: 'Belum ada postingan');
          }

          return ListView.builder(
            controller: scrollCtrl,
            itemCount: posts.length + 1, // tambah 1 buat indikator loading bawah
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: AppLoading(size: 48)),
                );
              }
              final post = posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }
}
