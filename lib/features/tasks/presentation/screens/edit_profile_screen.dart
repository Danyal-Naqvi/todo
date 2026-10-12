import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../widgets/user_avatar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _photoUrlController;

  // Selected avatar configuration
  // 'gallery' | 'asset' | 'preset_url' | 'custom_url' | 'initials'
  String _avatarType = 'asset';
  String? _selectedFilePath;
  String? _selectedAssetPath;
  String? _selectedImageUrl;
  int _selectedColorValue = 0xFFFF9E44;

  final List<Map<String, dynamic>> _presetAvatars = [
    {
      'type': 'asset',
      'label': 'Bruce',
      'asset': 'assets/images/bruce.jpg',
      'url': null,
    },
    {
      'type': 'preset_url',
      'label': 'Creative',
      'asset': null,
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&fit=crop&crop=faces',
    },
    {
      'type': 'preset_url',
      'label': 'Student',
      'asset': null,
      'url':
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&fit=crop&crop=faces',
    },
    {
      'type': 'preset_url',
      'label': 'Developer',
      'asset': null,
      'url':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&crop=faces',
    },
    {
      'type': 'preset_url',
      'label': 'Leader',
      'asset': null,
      'url':
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&fit=crop&crop=faces',
    },
    {
      'type': 'initials',
      'label': 'Initials',
      'asset': null,
      'url': null,
    },
  ];

  final List<int> _initialColors = [
    0xFFFF9E44, // Peach Orange
    0xFF5BA4FC, // Sky Blue
    0xFF42BAAE, // Mint Green
    0xFFA881FC, // Purple
    0xFFFA6551, // Crimson Coral
    0xFFFFB74D, // Amber
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state;
    _nameController = TextEditingController(text: profile.name);
    _roleController = TextEditingController(text: profile.role);
    _emailController = TextEditingController(text: profile.email);
    _bioController = TextEditingController(text: profile.bio);
    _photoUrlController = TextEditingController(text: profile.imageUrl ?? '');

    _selectedFilePath = profile.filePath;
    _selectedAssetPath = profile.assetPath;
    _selectedImageUrl = profile.imageUrl;
    _selectedColorValue = profile.avatarColorValue;

    if (profile.filePath != null && profile.filePath!.isNotEmpty) {
      _avatarType = 'gallery';
    } else if (profile.assetPath != null) {
      _avatarType = 'asset';
    } else if (profile.imageUrl != null) {
      _avatarType = 'preset_url';
    } else {
      _avatarType = 'initials';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _avatarType = 'gallery';
          _selectedFilePath = image.path;
          _selectedAssetPath = null;
          _selectedImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access gallery: $e'),
            backgroundColor: AppColors.statusCanceled,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppColors.statusCanceled,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String? filePath;
    bool clearFilePath = false;
    String? assetPath;
    bool clearAssetPath = false;
    String? imageUrl;
    bool clearImageUrl = false;

    if (_avatarType == 'gallery') {
      filePath = _selectedFilePath;
      clearAssetPath = true;
      clearImageUrl = true;
    } else if (_avatarType == 'asset') {
      assetPath = _selectedAssetPath ?? 'assets/images/bruce.jpg';
      clearFilePath = true;
      clearImageUrl = true;
    } else if (_avatarType == 'preset_url' || _avatarType == 'custom_url') {
      imageUrl = _selectedImageUrl ?? _photoUrlController.text.trim();
      clearFilePath = true;
      clearAssetPath = true;
    } else {
      // Initials monogram
      clearFilePath = true;
      clearAssetPath = true;
      clearImageUrl = true;
    }

    context.read<ProfileCubit>().updateProfile(
          name: name,
          role: _roleController.text.trim(),
          bio: _bioController.text.trim(),
          email: _emailController.text.trim(),
          filePath: filePath,
          clearFilePath: clearFilePath,
          assetPath: assetPath,
          clearAssetPath: clearAssetPath,
          imageUrl: imageUrl,
          clearImageUrl: clearImageUrl,
          avatarColorValue: _selectedColorValue,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully ✨'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.statusCompleted,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  UserProfile _getPreviewProfile() {
    final name = _nameController.text.trim().isEmpty
        ? 'User'
        : _nameController.text.trim();
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? 'U'
        : (parts.length == 1
            ? parts.first[0].toUpperCase()
            : '${parts.first[0]}${parts.last[0]}'.toUpperCase());

    return UserProfile(
      name: name,
      role: _roleController.text.trim(),
      bio: _bioController.text.trim(),
      email: _emailController.text.trim(),
      filePath: _avatarType == 'gallery' ? _selectedFilePath : null,
      assetPath: _avatarType == 'asset' ? _selectedAssetPath : null,
      imageUrl: (_avatarType == 'preset_url' || _avatarType == 'custom_url')
          ? _selectedImageUrl
          : null,
      initials: initials,
      avatarColorValue: _selectedColorValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewProfile = _getPreviewProfile();

    return Scaffold(
      backgroundColor: AppColors.dynamicBg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Pinned Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: NeoBrutalist.iconButton(context: context),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    key: const ValueKey('edit_profile_save_btn'),
                    onTap: _saveProfile,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3342)
                              : AppColors.borderBlack,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.6)
                                : AppColors.borderBlack,
                            offset: const Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Customization Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: NeoBrutalist.card(
                        context: context,
                        borderRadius: 22,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(0, 3.5),
                      ),
                      child: Column(
                        children: [
                          // Live Avatar Preview with Camera Badge
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                UserAvatarWidget.fromProfile(
                                  previewProfile,
                                  size: 96,
                                  showBorder: true,
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.borderBlack,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black
                                                .withValues(alpha: 0.6)
                                            : AppColors.borderBlack,
                                        offset: const Offset(0, 2),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.photo_camera_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                          Text(
                            'Choose Your Avatar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select from phone gallery or choose a preset character',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? const Color(0xFFA0A7B5)
                                  : AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Pick from Gallery Quick Button
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: _avatarType == 'gallery'
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : (isDark
                                        ? const Color(0xFF222632)
                                        : const Color(0xFFF7F8FA)),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _avatarType == 'gallery'
                                      ? AppColors.primary
                                      : (isDark
                                          ? const Color(0xFF2E3342)
                                          : const Color(0xFFE2E6EC)),
                                  width: _avatarType == 'gallery' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo_library_rounded,
                                    size: 18,
                                    color: _avatarType == 'gallery'
                                        ? AppColors.primary
                                        : (isDark
                                            ? Colors.white
                                            : AppColors.textPrimary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _avatarType == 'gallery'
                                        ? 'Photo Selected from Gallery ✓'
                                        : 'Upload from Phone Gallery',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: _avatarType == 'gallery'
                                          ? AppColors.primary
                                          : (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Preset Avatars Selector
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _presetAvatars.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final item = _presetAvatars[index];
                                final type = item['type'] as String;
                                final asset = item['asset'] as String?;
                                final url = item['url'] as String?;
                                final label = item['label'] as String;

                                final isSelected = (_avatarType == 'asset' &&
                                        type == 'asset' &&
                                        _selectedAssetPath == asset) ||
                                    (_avatarType == 'preset_url' &&
                                        type == 'preset_url' &&
                                        _selectedImageUrl == url) ||
                                    (_avatarType == 'initials' &&
                                        type == 'initials');

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _avatarType = type;
                                      _selectedFilePath = null;
                                      if (type == 'asset') {
                                        _selectedAssetPath = asset;
                                        _selectedImageUrl = null;
                                      } else if (type == 'preset_url') {
                                        _selectedImageUrl = url;
                                        _selectedAssetPath = null;
                                      } else {
                                        _selectedAssetPath = null;
                                        _selectedImageUrl = null;
                                      }
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : (isDark
                                                    ? const Color(0xFF383E4C)
                                                    : AppColors.borderBlack),
                                            width: isSelected ? 2.5 : 1.5,
                                          ),
                                          boxShadow: isSelected
                                              ? const [
                                                  BoxShadow(
                                                    color: AppColors.primary,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: ClipOval(
                                          child: type == 'asset'
                                              ? Image.asset(asset!,
                                                  fit: BoxFit.cover)
                                              : (type == 'preset_url'
                                                  ? Image.network(
                                                      url!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (context, error, stackTrace) =>
                                                              Container(
                                                        color: const Color(
                                                            0xFFE0E0E0),
                                                        child: const Icon(
                                                            Icons.person,
                                                            size: 20),
                                                      ),
                                                    )
                                                  : Container(
                                                      color: Color(
                                                          _selectedColorValue),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        previewProfile.initials,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    )),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : (isDark
                                                  ? const Color(0xFFA0A7B5)
                                                  : AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Color picker when initials is selected
                          if (_avatarType == 'initials') ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _initialColors.map((colorValue) {
                                final isColorSelected =
                                    _selectedColorValue == colorValue;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorValue = colorValue;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Color(colorValue),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isColorSelected
                                            ? Colors.white
                                            : (isDark
                                                ? const Color(0xFF383E4C)
                                                : AppColors.borderBlack),
                                        width: isColorSelected ? 2 : 1,
                                      ),
                                      boxShadow: isColorSelected
                                          ? const [
                                              BoxShadow(
                                                color: AppColors.borderBlack,
                                                offset: Offset(0, 2),
                                                blurRadius: 0,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: isColorSelected
                                        ? const Icon(Icons.check,
                                            size: 14, color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Custom Photo URL expansion
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF222632)
                                  : const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2E3342)
                                    : const Color(0xFFE2E6EC),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.link_rounded,
                                    size: 18,
                                    color: isDark
                                        ? const Color(0xFFA0A7B5)
                                        : AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _photoUrlController,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Or paste image URL...',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF6E7482)
                                            : AppColors.textMuted,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          _avatarType = 'custom_url';
                                          _selectedImageUrl = val.trim();
                                          _selectedAssetPath = null;
                                          _selectedFilePath = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                if (_photoUrlController.text
                                    .trim()
                                    .isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _photoUrlController.clear();
                                        _avatarType = 'asset';
                                        _selectedAssetPath =
                                            'assets/images/bruce.jpg';
                                        _selectedImageUrl = null;
                                        _selectedFilePath = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: isDark
                                          ? const Color(0xFFA0A7B5)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Information Section Title
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Full Name Field
                    _buildInputField(
                      context: context,
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      hintText: 'e.g. Bruce Wayne',
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 14),

                    // Occupation / Role Field
                    _buildInputField(
                      context: context,
                      label: 'Role or Occupation',
                      controller: _roleController,
                      icon: Icons.work_outline_rounded,
                      hintText: 'e.g. Product Designer, Student, Freelancer',
                    ),

                    const SizedBox(height: 14),

                    // Email Field
                    _buildInputField(
                      context: context,
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hintText: 'e.g. bruce.wayne@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 14),

                    // Bio / Motto Field
                    _buildInputField(
                      context: context,
                      label: 'Bio / Daily Motto',
                      controller: _bioController,
                      icon: Icons.format_quote_rounded,
                      hintText: 'e.g. Stay focused and make everyday count ✨',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 28),

                    // Save Changes Button
                    GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E3342)
                                : AppColors.borderBlack,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.7)
                                  : AppColors.borderBlack,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded,
                                size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes ✨',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFA0A7B5) : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: NeoBrutalist.card(
            context: context,
            borderRadius: 16,
            borderWidth: 1.5,
            shadowOffset: const Offset(0, 2.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: maxLines > 1 ? 12 : 4,
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
                child: Icon(icon,
                    size: 20,
                    color: isDark ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF6E7482)
                          : AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
