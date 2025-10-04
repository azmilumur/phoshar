import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoshar/features/auth/shared/auth_user.dart';
import 'features/auth/controllers/auth_controller.dart';

/// Provider yang bikin GoRouter otomatis refresh kalau state auth berubah.
/// Kita skip refresh saat state error supaya router gak redirect waktu register gagal.
final routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final ticker = ValueNotifier(0);

  ref.listen<AsyncValue<AuthUser?>>(authControllerProvider, (prev, next) {
    // ✅ hanya refresh kalau state bukan error
    // dan cuma kalau state benar-benar berubah (biar gak spam refresh)
    if (!next.hasError &&
        next != prev &&
        (next.isLoading || next.hasValue)) {
      ticker.value++;
      debugPrint('🔄 Router refresh triggered (state: ${next.runtimeType})');
    } else if (next.hasError) {
      debugPrint('⏸ Skip router refresh (error state)');
    }
  }, fireImmediately: true);

  ref.onDispose(ticker.dispose);
  return ticker;
});
