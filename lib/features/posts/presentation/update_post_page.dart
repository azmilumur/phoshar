import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../posts/controllers/update_post_controller.dart';

class UpdatePostPage extends ConsumerStatefulWidget {
  const UpdatePostPage({
    super.key,
    required this.postId,
    required this.initialImageUrl,
    required this.initialCaption,
  });

  final String postId;
  final String initialImageUrl;
  final String initialCaption;

  @override
  ConsumerState<UpdatePostPage> createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends ConsumerState<UpdatePostPage> {
  final _capCtrl = TextEditingController();
  XFile? _newImage;
  Uint8List? _newBytes;

  @override
  void initState() {
    super.initState();
    _capCtrl.text = widget.initialCaption;
  }

  @override
  void dispose() {
    _capCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource src) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: src, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes(); // web friendly
    setState(() {
      _newImage = picked;
      _newBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updatePostControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preview
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _newBytes != null
                  ? Image.memory(_newBytes!, fit: BoxFit.cover)
                  : (widget.initialImageUrl.isNotEmpty
                        ? Image.network(
                            widget.initialImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          )
                        : const Center(child: Icon(Icons.image, size: 48))),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Pilih dari Galeri'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _capCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final caption = _capCtrl.text.trim();
                      if (caption.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Caption tidak boleh kosong'),
                          ),
                        );
                        return;
                      }
                      await ref
                          .read(updatePostControllerProvider.notifier)
                          .submit(
                            postId: widget.postId,
                            currentImageUrl: widget.initialImageUrl,
                            caption: caption,
                            newImage: _newImage, // null = pakai url lama
                          );

                      final ok = ref
                          .read(updatePostControllerProvider)
                          .hasValue; // sukses

                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post diupdate')),
                        );
                        Navigator.of(context).pop(true); // return success
                      } else {
                        final err =
                            ref
                                .read(updatePostControllerProvider)
                                .error
                                ?.toString() ??
                            'Gagal update';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(err)));
                      }
                    },
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
