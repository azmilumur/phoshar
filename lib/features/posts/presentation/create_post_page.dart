import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
// optional kalau mau redirect ke profile
import '../controllers/create_post_controller.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _captionCtrl = TextEditingController();
  XFile? _picked;
  Uint8List? _previewBytes; // aman untuk web & mobile
  bool _picking = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _picked = file;
          _previewBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    final img = _picked;
    final caption = _captionCtrl.text.trim();
    if (img == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih gambar dulu.')));
      return;
    }
    if (caption.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Caption wajib diisi.')));
      return;
    }

    await ref
        .read(createPostControllerProvider.notifier)
        .submit(image: img, caption: caption);
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createPostControllerProvider);

    // listen sukses/error
    ref.listen(createPostControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post berhasil dibuat')));
          // setelah sukses, balik ke feed atau ke profile sendiri
          context.go('/'); // atau: context.go('/profile');
        },
        error: (e, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PREVIEW
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _previewBytes == null
                  ? const Center(child: Icon(Icons.image_outlined, size: 48))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _previewBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: createState.isLoading ? null : _pickImage,
                icon: _picking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(width: 12),
              if (_picked != null)
                Text(_picked!.name, overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionCtrl,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Caption',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: createState.isLoading ? null : _submit,
              child: createState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Upload & Post'),
            ),
          ),
        ],
      ),
    );
  }
}
