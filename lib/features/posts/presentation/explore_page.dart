import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/post_controller.dart';
import '../../posts/data/photo.dart';
import '../../../core/widgets/global_loading.dart';
import 'post_detail_page.dart'; // pastikan path sesuai project kamu

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    // 🚀 Load explore pertama kali
    Future.microtask(() {
      ref.read(postControllerProvider.notifier).loadExplorePosts();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() async {
    if (_isLoadingMore) return;

    final notifier = ref.read(postControllerProvider.notifier);
    if (!notifier.hasMore) return;

    // scroll 90% ke bawah → ambil data berikutnya
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      setState(() => _isLoadingMore = true);
      await notifier.loadMoreExplorePosts();
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(postControllerProvider.notifier).refreshExplorePosts();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Explore',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: postAsync.when(
          loading: () => const Center(child: GlobalLoadingWidget()),
          error: (err, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Terjadi kesalahan: $err'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Text('Belum ada postingan untuk ditampilkan.'),
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                itemCount: posts.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // 🔄 Spinner bawah
                  if (index == posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: GlobalLoadingWidget(),
                    );
                  }

                  final Photo post = posts[index];
                  final imageUrl = post.imageUrl;

                  // Placeholder kalau gak ada gambar
                  if (imageUrl.isEmpty) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    );
                  }

                  // 🖼️ Fade-in animation
                  return _FadeInImageTile(
                    imageUrl: imageUrl,
                    tag: 'post-${post.id}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(postId: post.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 🔮 Komponen reusable untuk gambar dengan efek fade-in halus
class _FadeInImageTile extends StatefulWidget {
  final String imageUrl;
  final String tag;
  final VoidCallback onTap;

  const _FadeInImageTile({
    required this.imageUrl,
    required this.tag,
    required this.onTap,
  });

  @override
  State<_FadeInImageTile> createState() => _FadeInImageTileState();
}

class _FadeInImageTileState extends State<_FadeInImageTile> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // delay kecil biar animasi smooth
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Hero(
        tag: widget.tag,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.grey[200]), // base placeholder
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
