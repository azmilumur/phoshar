import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networks/dio_client.dart';

class EditProfileRepository {
  final Dio _dio;
  EditProfileRepository(this._dio);

  Future<void> updateProfile({
    required String name,
    required String username,
    required String email,
    String? bio,
    String? website,
  }) async {
    await _dio.put(
      'update-profile',
      data: {
        'name': name,
        'username': username,
        'email': email,
        if (bio != null) 'bio': bio,
        if (website != null) 'website': website,
      },
    );
  }
}

final editProfileRepositoryProvider = Provider<EditProfileRepository>(
  (ref) => EditProfileRepository(ref.watch(dioClientProvider)),
);