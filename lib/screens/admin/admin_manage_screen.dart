import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/story_model.dart';
import '../../services/database_service.dart';
import '../membaca_cerita_screen.dart';
import 'admin_form_screen.dart';

class AdminManageScreen extends StatefulWidget {
  const AdminManageScreen({super.key});

  @override
  State<AdminManageScreen> createState() => _AdminManageScreenState();
}

class _AdminManageScreenState extends State<AdminManageScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _catColor(String cat) {
    switch (cat.toUpperCase()) {
      case 'LEGENDA':
        return const Color(0xFFBFD9FE);
      case 'MITOS':
        return const Color(0xFFDDD6FE);
      case 'FABEL':
        return const Color(0xFFC6F6D5);
      case 'FANTASI':
        return const Color(0xFFFFD1E6);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color _catTextColor(String cat) {
    switch (cat.toUpperCase()) {
      case 'LEGENDA':
        return const Color(0xFF1D5AA8);
      case 'MITOS':
        return const Color(0xFF5B21B6);
      case 'FABEL':
        return const Color(0xFF065F46);
      case 'FANTASI':
        return const Color(0xFF9C0E56);
      default:
        return const Color(0xFF374151);
    }
  }

  void _deleteStory(String id) {
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
          'Cerita yang dihapus tidak dapat dipulihkan. Lanjutkan?',
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
              Navigator.pop(context);
              try {
                await _databaseService.deleteStory(id);
                if (mounted) {
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
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Gagal menghapus cerita: $e',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFFDC2626),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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

  void _editStory(StoryModel story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminFormScreen(editStory: story)),
    );
  }

  Future<void> _approveStory(String id, String title) async {
    try {
      await _databaseService.approveStory(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cerita "$title" disetujui dan dipublikasikan! ✅',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF00743B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyetujui cerita: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _rejectStory(String id, String title) async {
    try {
      await _databaseService.rejectStory(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cerita "$title" ditolak.',
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menolak cerita: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Cerita',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF065F46),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manajemen cerita dan moderasi kiriman pengguna.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: const Color(0xFF64655C),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                labelColor: const Color(0xFF00743B),
                unselectedLabelColor: const Color(0xFF9CA3AF),
                indicatorColor: const Color(0xFF00743B),
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  StreamBuilder<List<StoryModel>>(
                    stream: _databaseService.getPendingStories(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Perlu Validasi'),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const Tab(text: 'Semua Cerita'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 1: Pending Stories ──
                  _PendingStoriesTab(
                    databaseService: _databaseService,
                    onApprove: _approveStory,
                    onReject: _rejectStory,
                    catColor: _catColor,
                    catTextColor: _catTextColor,
                  ),
                  // ── Tab 2: All Stories ──
                  _AllStoriesTab(
                    databaseService: _databaseService,
                    onEdit: _editStory,
                    onDelete: _deleteStory,
                    catColor: _catColor,
                    catTextColor: _catTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// PENDING STORIES TAB
// ──────────────────────────────────────────────────────────────
class _PendingStoriesTab extends StatelessWidget {
  final DatabaseService databaseService;
  final Future<void> Function(String id, String title) onApprove;
  final Future<void> Function(String id, String title) onReject;
  final Color Function(String) catColor;
  final Color Function(String) catTextColor;

  const _PendingStoriesTab({
    required this.databaseService,
    required this.onApprove,
    required this.onReject,
    required this.catColor,
    required this.catTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StoryModel>>(
      stream: databaseService.getPendingStories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00743B)),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.beVietnamPro(color: const Color(0xFF64655C)),
            ),
          );
        }

        final stories = snapshot.data ?? [];
        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: Color(0xFF00743B),
                ),
                const SizedBox(height: 12),
                Text(
                  'Semua cerita sudah divalidasi! ✅',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF065F46),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tidak ada cerita yang menunggu persetujuan.',
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
          itemCount: stories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final story = stories[i];
            final dateStr =
                '${story.timestamp.day}/${story.timestamp.month}/${story.timestamp.year}';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pending_rounded,
                          size: 12,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Menunggu Validasi',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Story info
                  Row(
                    children: [
                      // Cover preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: story.imagePath.startsWith('http')
                            ? Image.network(
                                story.imagePath,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _PlaceholderCover(),
                              )
                            : Image.asset(
                                story.imagePath,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _PlaceholderCover(),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF373830),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: catColor(story.category),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    story.category,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: catTextColor(story.category),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    story.authorName,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 12,
                                      color: const Color(0xFF64655C),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dikirim: $dateStr',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Story preview
                  if (story.part1.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.part1.length > 180
                              ? '${story.part1.substring(0, 180)}...'
                              : story.part1,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: const Color(0xFF64655C),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembacaCeritaScreen(story: story),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Baca Selengkapnya',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: Color(0xFF2563EB),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onApprove(story.id, story.title),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(
                            'Setujui',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00743B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onReject(story.id, story.title),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text(
                            'Tolak',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ALL STORIES TAB
// ──────────────────────────────────────────────────────────────
class _AllStoriesTab extends StatelessWidget {
  final DatabaseService databaseService;
  final void Function(StoryModel) onEdit;
  final void Function(String) onDelete;
  final Color Function(String) catColor;
  final Color Function(String) catTextColor;

  const _AllStoriesTab({
    required this.databaseService,
    required this.onEdit,
    required this.onDelete,
    required this.catColor,
    required this.catTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StoryModel>>(
      stream: databaseService.getAllStoriesForAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00743B)),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
        }

        final stories = snapshot.data ?? [];

        if (stories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: Color(0xFFBABAAF),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada cerita.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF64655C),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
          itemCount: stories.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final story = stories[i];
            final dateStr =
                '${story.timestamp.day}/${story.timestamp.month}/${story.timestamp.year}';

            // Status color
            Color statusBg;
            Color statusText;
            String statusLabel;
            if (story.isApproved) {
              statusBg = const Color(0xFFD1FAE5);
              statusText = const Color(0xFF065F46);
              statusLabel = 'Disetujui';
            } else if (story.isPending) {
              statusBg = const Color(0xFFFEF3C7);
              statusText = const Color(0xFFD97706);
              statusLabel = 'Pending';
            } else {
              statusBg = const Color(0xFFFEE2E2);
              statusText = const Color(0xFFDC2626);
              statusLabel = 'Ditolak';
            }

            return Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC6F6D5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00743B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF373830),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Author name
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              story.authorName,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                color: const Color(0xFF64655C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: catColor(story.category),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                story.category,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: catTextColor(story.category),
                                ),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: statusText,
                                ),
                              ),
                            ),
                            Text(
                              dateStr,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 11,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        bg: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF2563EB),
                        onTap: () => onEdit(story),
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.delete_rounded,
                        bg: const Color(0xFFFEE2E2),
                        iconColor: const Color(0xFFDC2626),
                        onTap: () => onDelete(story.id),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFE5E7EB),
      child: const Icon(
        Icons.image_not_supported_rounded,
        color: Color(0xFF9CA3AF),
        size: 24,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
