import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class UserAvatarWidget extends StatelessWidget {
  final double size;
  final String? assetPath;
  final String? imageUrl;
  final String initials;
  final Color backgroundColor;
  final bool showBorder;

  const UserAvatarWidget({
    super.key,
    this.size = 46,
    this.assetPath = 'assets/images/bruce.jpg',
    this.imageUrl,
    this.initials = 'BW',
    this.backgroundColor = const Color(0xFFFF9E44),
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: showBorder
            ? Border.all(color: AppColors.borderBlack, width: 1.5)
            : null,
      ),
      child: ClipOval(
        child: assetPath != null
            ? Image.asset(
                assetPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackAvatar(),
              )
            : (imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackAvatar(),
                  )
                : _buildFallbackAvatar()),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AvatarStackWidget extends StatelessWidget {
  final double avatarSize;
  final VoidCallback? onAddTap;

  const AvatarStackWidget({
    super.key,
    this.avatarSize = 28,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColors = [
      const Color(0xFF5BA4FC),
      const Color(0xFFFF9E44),
      const Color(0xFF42BAAE),
    ];
    final avatarInitials = ['JR', 'AT', 'BW'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: avatarSize,
          width: avatarSize + (avatarColors.length - 1) * (avatarSize * 0.65),
          child: Stack(
            children: List.generate(avatarColors.length, (index) {
              return Positioned(
                left: index * (avatarSize * 0.65),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarColors[index],
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarInitials[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: avatarSize * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (onAddTap != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF5B335),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
