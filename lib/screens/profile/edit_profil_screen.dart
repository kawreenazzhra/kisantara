import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../utils/localization.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = true;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  String _currentPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (profile != null) {
        _nameController.text = profile.penName;
        _emailController.text = profile.email;
        _bioController.text = profile.bio;
        _currentPhotoUrl = profile.photoUrl;
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageFile = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.translate('gagal_pilih_gambar')}: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _saveProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? newPhotoUrl;
        if (_imageFile != null && _imageBytes != null) {
          final storageService = StorageService();
          final name = _imageFile!.name.toLowerCase();
          final ext = name.contains('.') ? name.split('.').last : 'jpg';
          final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
          final fileName =
              'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';

          newPhotoUrl = await storageService.uploadBytes(
            _imageBytes!,
            fileName,
            mimeType,
          );
        }

        await _authService.updateUserProfile(
          uid: user.uid,
          penName: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          photoUrl: newPhotoUrl,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.translate('profil_diperbarui'),
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: const Color(0xFF00743B),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.translate('gagal_perbarui_profil')}: $e',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFDF1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF064E3B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.translate('edit_profil'),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                fontSize: 18,
              ),
            ),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00743B)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture Section
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: _imageBytes != null
                                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                    : (_currentPhotoUrl.isNotEmpty
                                          ? Image.network(
                                              _currentPhotoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/images/user_avatar.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                            )
                                          : Image.asset(
                                              'assets/images/user_avatar.png',
                                              fit: BoxFit.cover,
                                            )),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00743B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Input
                      _buildInputField(
                        label: AppLocalizations.translate('nama_lengkap'),
                        controller: _nameController,
                        hint: AppLocalizations.translate('masukkan_nama'),
                        icon: Icons.person_outline_rounded,
                      ),

                      // Email Input (Read only)
                      _buildInputField(
                        label: AppLocalizations.translate('email_notif_cerita'),
                        controller: _emailController,
                        hint: AppLocalizations.translate('masukkan_email'),
                        icon: Icons.email_outlined,
                        enabled: false,
                      ),

                      // Bio Input
                      _buildInputField(
                        label: AppLocalizations.translate('bio'),
                        controller: _bioController,
                        hint: AppLocalizations.translate('tulis_tentang_kamu'),
                        icon: Icons.info_outline_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 48),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00743B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.translate('simpan_perubahan'),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF064E3B),
              fontSize: 14,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF064E3B).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            style: GoogleFonts.beVietnamPro(
              color: enabled
                  ? const Color(0xFF373830)
                  : const Color(0xFF9CA3AF),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.beVietnamPro(
                color: const Color(0xFFB4B4B4),
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF00743B), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
