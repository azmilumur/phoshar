// lib/features/profile/controllers/profile_counts_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/session_controller.dart';
import '../data/user_repository.dart';

final profileCountsProvider = FutureProvider.family<FollowCounts, String>((
  ref,
  targetUserId,
) async {
  final me = ref.read(sessionControllerProvider).asData?.value;
  final repo = ref.read(userRepositoryProvider);
  if (me != null && me.id == targetUserId) {
    return repo.getMyCounts(targetUserId);
  }
  return repo.getCountsOf(targetUserId);
});
