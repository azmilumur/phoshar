import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoshar/features/auth/data/auth_repository.dart';
import 'features/auth/controllers/auth_controller.dart';

// Ubah event Riverpod -> Listenable (tanpa .stream)
final routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final ticker = ValueNotifier(0);
  // Trigger notify setiap auth state berubah
  ref.listen<AsyncValue<AuthUser?>>(authControllerProvider, (_, __) {
    ticker.value++; // bump value -> notifyListeners()
  }, fireImmediately: true);

  ref.onDispose(ticker.dispose);
  return ticker;
});
