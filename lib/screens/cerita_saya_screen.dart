import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'membaca_cerita_screen.dart';
import 'write_story_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/story_model.dart';

class CeritaSayaScreen extends StatefulWidget {
  const CeritaSayaScreen({super.key});

  @override
  State<CeritaSayaScreen> createState() => _CeritaSayaScreenState();
}

class _CeritaSayaScreenState extends State<CeritaSayaScreen> {
  int _selectedTab = 0; // 0 = Disimpan, 1 = Terakhir Dibaca, 2 = Tulisan Saya
  final _authService = AuthService();
  final _databaseService = DatabaseService();

  void _deleteStory(String storyId, String storyTitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Cerita?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF065F46),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$storyTitle"? Cerita yang dihapus tidak dapat dipulihkan.',
          style: GoogleFonts.beVietnamPro(color: const Color(0xFF64655C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64655C),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _databaseService.deleteStory(storyId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cerita berhasil dihapus.',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFEFDF1),
        body: Center(child: Text('Silakan login terlebih dahulu.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      floatingActionButton: _selectedTab == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WriteStoryScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF00743B),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_note_rounded),
              label: Text(
                'Tulis Cerita',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            )
          : null,
      floatingActionButtonLocation: const _CustomFloatingActionButtonLocation(),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Cerita Saya',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                  letterSpacing: -0.6,
                ),
              ),
            ),
            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TabItem(
                      title: 'Disimpan',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                    const SizedBox(width: 12),
                    _TabItem(
                      title: 'Terakhir Dibaca',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                    const SizedBox(width: 12),
                    _TabItem(
                      title: 'Tulisan Saya',
                      isSelected: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // List of Stories from Firestore
            Expanded(
              child: StreamBuilder<List<StoryModel>>(
                stream: _selectedTab == 0
                    ? _databaseService.getBookmarkedStories(user.uid)
                    : _selectedTab == 1
                    ? _databaseService.getRecentlyReadStories(user.uid)
                    : _databaseService.getUserStories(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00743B),
                      ),
                    );
                  }

                  final listToShow = snapshot.data ?? [];
                  if (listToShow.isEmpty) {
                    String emptyText = 'Belum ada cerita disimpan.';
                    IconData emptyIcon = Icons.bookmark_border_rounded;
                    if (_selectedTab == 1) {
                      emptyText = 'Belum ada riwayat membaca.';
                      emptyIcon = Icons.history_rounded;
                    } else if (_selectedTab == 2) {
                      emptyText = 'Anda belum menulis cerita apapun.';
                      emptyIcon = Icons.draw_rounded;
                    }

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            emptyIcon,
                            size: 64,
                            color: const Color(0xFFBABAAF),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            emptyText,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64655C),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                    itemCount: listToShow.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final story = listToShow[index];
                      return _StoryListTile(
                        story: story,
                        isOwnWork: _selectedTab == 2,
                        onDelete: () => _deleteStory(story.id, story.title),
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WriteStoryScreen(editStory: story),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00743B) : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00743B)
                : const Color(0xFFBABAAF).withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64655C),
          ),
        ),
      ),
    );
  }
}

class _StoryListTile extends StatelessWidget {
  final StoryModel story;
  final bool isOwnWork;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _StoryListTile({
    required this.story,
    this.isOwnWork = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (story.imagePath.startsWith('http')) {
      imageWidget = Image.network(
        story.imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: const Color(0xFFE5E7EB),
            child: const Icon(
              Icons.image_not_supported_rounded,
              color: Color(0xFF9CA3AF),
            ),
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        story.imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: const Color(0xFFE5E7EB),
            child: const Icon(
              Icons.image_not_supported_rounded,
              color: Color(0xFF9CA3AF),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MembacaCeritaScreen(story: story),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064E3B).withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: story.categoryColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      story.category,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: story.categoryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF373830),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Show status badge for user's own stories
                  if (isOwnWork && story.isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '⏳ Menunggu persetujuan admin',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    )
                  else if (isOwnWork && story.isRejected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '❌ Ditolak oleh admin',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Color(0xFF64655C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        story.readTime,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          color: const Color(0xFF64655C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isOwnWork) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ] else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFBABAAF)),
          ],
        ),
      ),
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  const _CustomFloatingActionButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standardOffset = FloatingActionButtonLocation.endFloat
        .getOffset(scaffoldGeometry);
    // Move the FAB 88 pixels higher to sit nicely above the navigation bar
    return Offset(standardOffset.dx, standardOffset.dy - 88);
  }
}
