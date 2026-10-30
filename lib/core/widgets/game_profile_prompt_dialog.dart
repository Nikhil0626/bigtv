import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/zip_puzzle_repository.dart';
import 'package:chotanews/features/patches_puzzle/data/repositories/patches_puzzle_repository.dart';
import 'package:chotanews/features/sudoku_puzzle/data/repositories/sudoku_puzzle_repository.dart';

class GameProfileData {
  final String name;
  final String photoUrl;
  final bool hasValidName;

  const GameProfileData({
    required this.name,
    required this.photoUrl,
    required this.hasValidName,
  });
}

class GameProfileManager {
  static const String keyGameProfileName = 'game_profile_name';
  static const String keyGameProfilePhoto = 'game_profile_photo';

  static bool isValidPlayerName(String? name) {
    if (name == null) return false;
    final clean = name.trim();
    if (clean.isEmpty) return false;
    final lower = clean.toLowerCase();
    if (lower == 'player' ||
        lower == 'you' ||
        lower == 'guest' ||
        lower.startsWith('guest') ||
        lower.startsWith('player') ||
        RegExp(r'^user\d{4,}$', caseSensitive: false).hasMatch(lower)) {
      return false;
    }
    return true;
  }

  /// Resolves the unified player profile across all games and global profile keys.
  static Future<GameProfileData> getUnifiedProfile({ProfileProvider? profileProvider}) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Check direct unified game profile keys first
    String resolvedName = prefs.getString(keyGameProfileName)?.trim() ?? '';
    String resolvedPhoto = prefs.getString(keyGameProfilePhoto)?.trim() ?? '';

    // 2. Check global user profile keys
    if (!isValidPlayerName(resolvedName)) {
      final userName = prefs.getString('userName')?.trim() ?? '';
      if (isValidPlayerName(userName)) {
        resolvedName = userName;
      }
    }

    // 3. Check individual game repositories keys
    if (!isValidPlayerName(resolvedName)) {
      final zipName = prefs.getString('zip_puzzle_v1_player_name')?.trim() ?? '';
      if (isValidPlayerName(zipName)) {
        resolvedName = zipName;
      }
    }
    if (!isValidPlayerName(resolvedName)) {
      final patchName = prefs.getString('patches_puzzle_v1_player_name')?.trim() ?? '';
      if (isValidPlayerName(patchName)) {
        resolvedName = patchName;
      }
    }
    if (!isValidPlayerName(resolvedName)) {
      final sudokuName = prefs.getString('sudoku_player_display_name')?.trim() ?? '';
      if (isValidPlayerName(sudokuName)) {
        resolvedName = sudokuName;
      }
    }

    // 4. Check ProfileProvider if available
    if (profileProvider != null) {
      if (!isValidPlayerName(resolvedName)) {
        final provName = profileProvider.nameController.text.trim();
        if (isValidPlayerName(provName)) {
          resolvedName = provName;
        } else if (profileProvider.profileData != null && profileProvider.profileData['profile'] is Map) {
          final dataName = profileProvider.profileData['profile']['name']?.toString().trim() ?? '';
          if (isValidPlayerName(dataName)) {
            resolvedName = dataName;
          }
        }
      }

      if (resolvedPhoto.isEmpty) {
        if (profileProvider.uploadImageUrl.trim().isNotEmpty) {
          resolvedPhoto = profileProvider.uploadImageUrl.trim();
        } else if (profileProvider.profileData != null && profileProvider.profileData['profile'] is Map) {
          final dataPhoto = profileProvider.profileData['profile']['photo']?.toString().trim() ?? '';
          if (dataPhoto.isNotEmpty) {
            resolvedPhoto = dataPhoto;
          }
        }
      }
    }

    // Fallback photo checks
    if (resolvedPhoto.isEmpty) {
      resolvedPhoto = prefs.getString('userPhoto')?.trim() ??
          prefs.getString('userImage')?.trim() ??
          '';
    }

    // If we resolved a valid name, ensure all repositories and keys have it synced in cache!
    if (isValidPlayerName(resolvedName)) {
      await prefs.setString(keyGameProfileName, resolvedName);
      await prefs.setString('userName', resolvedName);
      await prefs.setString('zip_puzzle_v1_player_name', resolvedName);
      await prefs.setString('patches_puzzle_v1_player_name', resolvedName);
      await prefs.setString('sudoku_player_display_name', resolvedName);
      if (resolvedPhoto.isNotEmpty) {
        await prefs.setString(keyGameProfilePhoto, resolvedPhoto);
        await prefs.setString('userPhoto', resolvedPhoto);
        await prefs.setString('userImage', resolvedPhoto);
      }
    }

    return GameProfileData(
      name: resolvedName,
      photoUrl: resolvedPhoto,
      hasValidName: isValidPlayerName(resolvedName),
    );
  }

  /// Saves the player profile uniformly to all game keys and global storage.
  static Future<void> saveUnifiedProfile({
    required String name,
    required String photoUrl,
    ProfileProvider? profileProvider,
  }) async {
    final cleanName = name.trim();
    final cleanPhoto = photoUrl.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyGameProfileName, cleanName);
    await prefs.setString('userName', cleanName);
    await prefs.setString('zip_puzzle_v1_player_name', cleanName);
    await prefs.setString('patches_puzzle_v1_player_name', cleanName);
    await prefs.setString('sudoku_player_display_name', cleanName);
    await prefs.setBool('has_updated_game_profile', true);

    if (cleanPhoto.isNotEmpty) {
      await prefs.setString(keyGameProfilePhoto, cleanPhoto);
      await prefs.setString('userPhoto', cleanPhoto);
      await prefs.setString('userImage', cleanPhoto);
    }

    // Sync individual repositories
    try {
      await ZipPuzzleRepository().setPlayerName(cleanName);
    } catch (_) {}
    try {
      await PatchesPuzzleRepository().setPlayerName(cleanName);
    } catch (_) {}
    try {
      await SudokuPuzzleRepository().setPlayerDisplayName(cleanName);
    } catch (_) {}

    // Update ProfileProvider in memory and call postProfile()
    if (profileProvider != null) {
      profileProvider.nameController.text = cleanName;
      if (cleanPhoto.isNotEmpty) {
        profileProvider.uploadImageUrl = cleanPhoto;
      }
      try {
        await profileProvider.postProfile();
      } catch (e) {
        debugPrint('Error posting unified profile to backend: $e');
      }
    }
  }
}

class GameProfilePromptDialog extends StatefulWidget {
  final String initialName;
  final String initialPhotoUrl;
  final String userId;
  final Future<void> Function(String name, String photoUrl) onProfileSaved;

  const GameProfilePromptDialog({
    super.key,
    required this.initialName,
    required this.initialPhotoUrl,
    required this.userId,
    required this.onProfileSaved,
  });

  @override
  State<GameProfilePromptDialog> createState() => _GameProfilePromptDialogState();
}

class _GameProfilePromptDialogState extends State<GameProfilePromptDialog> {
  late TextEditingController _nameController;
  File? _pickedFile;
  late String _photoUrl;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedFile = File(result.files.single.path!);
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();
      String finalPhotoUrl = _photoUrl;

      // 1. Upload photo if selected
      if (_pickedFile != null) {
        try {
          await profileProvider.uploadFile(_pickedFile!.path, widget.userId);
          if (profileProvider.uploadImageUrl.isNotEmpty) {
            finalPhotoUrl = profileProvider.uploadImageUrl;
          }
        } catch (e) {
          debugPrint('Error uploading profile image: $e');
        }
      }

      // 2. Persist unified profile across ALL games and storage keys
      await GameProfileManager.saveUnifiedProfile(
        name: name,
        photoUrl: finalPhotoUrl,
        profileProvider: profileProvider,
      );

      // 3. Notify caller with saved details
      await widget.onProfileSaved(name, finalPhotoUrl);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E2024) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: cardBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFF10B981),
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 12.h),

              // Title
              Text(
                'Join the Leaderboard!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 6.h),

              // Subtitle
              Text(
                'Add your name and profile picture to show your score and rank on today\'s leaderboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: subtextColor,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 20.h),

              // Profile Picture Avatar Selector
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isSaving ? null : _pickImage,
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF2A2D35) : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _pickedFile != null
                              ? Image.file(
                                  _pickedFile!,
                                  width: 90.w,
                                  height: 90.w,
                                  fit: BoxFit.cover,
                                )
                              : _photoUrl.isNotEmpty
                                  ? Image.network(
                                      _photoUrl,
                                      width: 90.w,
                                      height: 90.w,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person_rounded,
                                        size: 48.sp,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 48.sp,
                                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                                    ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Tap to choose profile photo',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 18.h),

              // Name Input Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _nameController,
                enabled: !_isSaving,
                maxLength: 25,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  counterText: '',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF16181C) : const Color(0xFFF8FAFC),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF33363D) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF33363D) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 20.h),

              // Save & Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 1,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save & View Leaderboard',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 6.h),

              // Skip text button
              TextButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final enteredName = _nameController.text.trim();
                        if (GameProfileManager.isValidPlayerName(enteredName)) {
                          try {
                            await GameProfileManager.saveUnifiedProfile(
                              name: enteredName,
                              photoUrl: _photoUrl,
                              profileProvider: context.read<ProfileProvider>(),
                            );
                          } catch (_) {}
                          await widget.onProfileSaved(enteredName, _photoUrl);
                        } else {
                          final fallbackName = widget.initialName.isNotEmpty ? widget.initialName : 'Player';
                          await widget.onProfileSaved(fallbackName, _photoUrl);
                        }
                        if (mounted) navigator.pop();
                      },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: subtextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
