import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/session_controller.dart'; // pastikan ada
import '../data/user_repository.dart';
import '../data/user_profile.dart';

/// Header profil:
/// - kalau dirinya sendiri → ambil dari session
/// - kalau user lain → fallback minimal (karena tidak ada endpoint detail)
final userHeaderProvider = FutureProvider.family<UserProfile, String>((
  ref,
  targetId,
) async {
  final me = ref.read(sessionControllerProvider).asData?.value;
  final repo = ref.read(userRepositoryProvider);
  if (me != null && me.id == targetId) {
    return UserProfile(
      id: me.id,
      name: me.name ?? me.username ?? me.email,
      username: me.username ?? '',
      email: me.email,
      avatarUrl: me.profilePictureUrl,
      bio: me.bio,
      website: me.website,
    );
  }
  return repo.getUserHeaderFallback(targetId);
});

/// Counts posts/followers/following
final profileCountsProvider = FutureProvider.family<FollowCounts, String>((
  ref,
  targetId,
) async {
  final me = ref.read(sessionControllerProvider).asData?.value;
  final repo = ref.read(userRepositoryProvider);
  if (me != null && me.id == targetId) return repo.getMyCounts(targetId);
  return repo.getCountsOf(targetId);
});
