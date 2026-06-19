import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile/edit_profil_screen.dart';
import 'profile/notifikasi_screen.dart';
import 'profile/bahasa_screen.dart';
import 'profile/bantuan_screen.dart';
import 'auth/login_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../models/story_model.dart';
import '../utils/localization.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, _, _lang) {
        final authService = AuthService();
        final currentUser = authService.currentUser;

        if (currentUser == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFFEFDF1),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          body: SafeArea(
            child: StreamBuilder<UserModel?>(
              stream: authService.getUserProfileStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00743B)),
                  );
                }

                final userProfile = snapshot.data;
                final penName = userProfile?.penName ?? 'Penjelajah Kisantara';
                final email =
                    userProfile?.email ??
                    currentUser.email ??
                    'penjelajah@kisantara.id';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Avatar
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilScreen(),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child:
                                    (userProfile?.photoUrl != null &&
                                        userProfile!.photoUrl.isNotEmpty)
                                    ? Image.network(
                                        userProfile.photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/images/user_avatar.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                    : Image.asset(
                                        'assets/images/user_avatar.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00743B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        penName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          color: const Color(0xFF64655C),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Stats row
                      _UserStatsRow(userId: currentUser.uid),
                      const SizedBox(height: 32),
                      // Menu items
                      _MenuItem(
                        icon: Icons.person_rounded,
                        label: AppLocalizations.translate('edit_profil'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        label: AppLocalizations.translate('notifikasi'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotifikasiScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: AppLocalizations.translate('bahasa'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BahasaScreen(),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: AppLocalizations.translate('bantuan'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BantuanScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.translate('sudah_keluar'),
                                  style: GoogleFonts.plusJakartaSans(),
                                ),
                                backgroundColor: const Color(0xFFDC2626),
                              ),
                            );
                            // Navigate to LoginScreen and clear navigation stack
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFDC2626),
                          ),
                          label: Text(
                            AppLocalizations.translate('keluar'),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: Color(0xFFDC2626),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF75F39C).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF00743B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              color: const Color(0xFF064E3B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF75F39C).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00743B), size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF373830),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF64655C),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _UserStatsRow extends StatelessWidget {
  final String userId;
  const _UserStatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    
    return StreamBuilder<List<StoryModel>>(
      stream: db.getRecentlyReadStories(userId),
      builder: (context, readSnap) {
        return StreamBuilder<List<StoryModel>>(
          stream: db.getBookmarkedStories(userId),
          builder: (context, savedSnap) {
            return StreamBuilder<List<StoryModel>>(
              stream: db.getUserStories(userId),
              builder: (context, authoredSnap) {
                
                final readCount = readSnap.data?.length ?? 0;
                final savedCount = savedSnap.data?.length ?? 0;
                final authoredCount = authoredSnap.data?.where((s) => s.isApproved).length ?? 0;
                
                int badgeCount = 0;
                if (readCount >= 1) badgeCount++;
                if (readCount >= 5) badgeCount++;
                if (savedCount >= 1) badgeCount++;
                if (savedCount >= 5) badgeCount++;
                if (authoredCount >= 1) badgeCount++;
                if (authoredCount >= 3) badgeCount++;

                return Row(
                  children: [
                    Expanded(child: _StatCard(value: '$readCount', label: AppLocalizations.translate('cerita_dibaca'))),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(value: '$badgeCount', label: AppLocalizations.translate('lencana'))),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(value: '$savedCount', label: AppLocalizations.translate('disimpan'))),
                  ],
                );
              }
            );
          }
        );
      }
    );
  }
}
