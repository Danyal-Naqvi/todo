import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile.dart';

class ProfileCubit extends Cubit<UserProfile> {
  static const String _kName = 'profile_name';
  static const String _kRole = 'profile_role';
  static const String _kBio = 'profile_bio';
  static const String _kEmail = 'profile_email';
  static const String _kAssetPath = 'profile_asset_path';
  static const String _kImageUrl = 'profile_image_url';
  static const String _kFilePath = 'profile_file_path';
  static const String _kInitials = 'profile_initials';
  static const String _kAvatarColor = 'profile_avatar_color';

  ProfileCubit({UserProfile? initialProfile})
      : super(initialProfile ?? const UserProfile()) {
    if (initialProfile == null) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_kName);
      if (name != null && name.trim().isNotEmpty) {
        emit(
          UserProfile(
            name: name,
            role: prefs.getString(_kRole) ?? 'Product Designer',
            bio: prefs.getString(_kBio) ??
                'Keep making progress every single day ✨',
            email: prefs.getString(_kEmail) ?? 'bruce.wayne@email.com',
            assetPath: prefs.getString(_kAssetPath),
            imageUrl: prefs.getString(_kImageUrl),
            filePath: prefs.getString(_kFilePath),
            initials: prefs.getString(_kInitials) ?? _computeInitials(name),
            avatarColorValue: prefs.getInt(_kAvatarColor) ?? 0xFFFF9E44,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> updatePhotoFromFile(String path) async {
    final updated = state.copyWith(
      filePath: path,
      clearAssetPath: true,
      clearImageUrl: true,
    );
    emit(updated);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kFilePath, path);
      await prefs.remove(_kAssetPath);
      await prefs.remove(_kImageUrl);
    } catch (_) {}
  }

  Future<void> updateProfile({
    required String name,
    required String role,
    required String bio,
    required String email,
    String? assetPath,
    bool clearAssetPath = false,
    String? imageUrl,
    bool clearImageUrl = false,
    String? filePath,
    bool clearFilePath = false,
    int? avatarColorValue,
  }) async {
    final finalName = name.trim().isEmpty ? state.name : name.trim();
    final finalRole = role.trim().isEmpty ? state.role : role.trim();
    final finalInitials = _computeInitials(finalName);

    String? finalAssetPath = state.assetPath;
    if (clearAssetPath) {
      finalAssetPath = null;
    } else if (assetPath != null) {
      finalAssetPath = assetPath;
    }

    String? finalImageUrl = state.imageUrl;
    if (clearImageUrl) {
      finalImageUrl = null;
    } else if (imageUrl != null) {
      finalImageUrl = imageUrl;
    }

    String? finalFilePath = state.filePath;
    if (clearFilePath) {
      finalFilePath = null;
    } else if (filePath != null) {
      finalFilePath = filePath;
    }

    final updated = state.copyWith(
      name: finalName,
      role: finalRole,
      bio: bio.trim(),
      email: email.trim(),
      assetPath: finalAssetPath,
      clearAssetPath: clearAssetPath,
      imageUrl: finalImageUrl,
      clearImageUrl: clearImageUrl,
      filePath: finalFilePath,
      clearFilePath: clearFilePath,
      initials: finalInitials,
      avatarColorValue: avatarColorValue ?? state.avatarColorValue,
    );
    emit(updated);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kName, updated.name);
      await prefs.setString(_kRole, updated.role);
      await prefs.setString(_kBio, updated.bio);
      await prefs.setString(_kEmail, updated.email);
      if (updated.assetPath != null) {
        await prefs.setString(_kAssetPath, updated.assetPath!);
      } else {
        await prefs.remove(_kAssetPath);
      }
      if (updated.imageUrl != null) {
        await prefs.setString(_kImageUrl, updated.imageUrl!);
      } else {
        await prefs.remove(_kImageUrl);
      }
      if (updated.filePath != null) {
        await prefs.setString(_kFilePath, updated.filePath!);
      } else {
        await prefs.remove(_kFilePath);
      }
      await prefs.setString(_kInitials, updated.initials);
      await prefs.setInt(_kAvatarColor, updated.avatarColorValue);
    } catch (_) {}
  }

  static String _computeInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
