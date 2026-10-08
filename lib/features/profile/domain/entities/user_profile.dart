import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String role;
  final String bio;
  final String email;
  final String? assetPath;
  final String? imageUrl;
  final String? filePath;
  final String initials;
  final int avatarColorValue;

  const UserProfile({
    this.name = 'Bruce Wayne',
    this.role = 'Product Designer',
    this.bio = 'Keep making progress every single day ✨',
    this.email = 'bruce.wayne@email.com',
    this.assetPath = 'assets/images/bruce.jpg',
    this.imageUrl,
    this.filePath,
    this.initials = 'BW',
    this.avatarColorValue = 0xFFFF9E44,
  });

  UserProfile copyWith({
    String? name,
    String? role,
    String? bio,
    String? email,
    String? assetPath,
    bool clearAssetPath = false,
    String? imageUrl,
    bool clearImageUrl = false,
    String? filePath,
    bool clearFilePath = false,
    String? initials,
    int? avatarColorValue,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      assetPath: clearAssetPath ? null : (assetPath ?? this.assetPath),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      filePath: clearFilePath ? null : (filePath ?? this.filePath),
      initials: initials ?? this.initials,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }

  @override
  List<Object?> get props => [
        name,
        role,
        bio,
        email,
        assetPath,
        imageUrl,
        filePath,
        initials,
        avatarColorValue,
      ];
}
