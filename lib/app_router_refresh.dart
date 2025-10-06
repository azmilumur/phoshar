import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/controllers/session_controller.dart';

final routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final tick = ValueNotifier(0);
  ref.listen(
    sessionControllerProvider,
    (_, __) => tick.value++,
    fireImmediately: true,
  );
  ref.onDispose(tick.dispose);
  return tick;
});
