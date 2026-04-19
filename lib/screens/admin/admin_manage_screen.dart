import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Dummy story data for admin management table
class _AdminStory {
  final String id;
  String title;
  String category;
  String date;

  _AdminStory({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
  });
}

class AdminManageScreen extends StatefulWidget {
  const AdminManageScreen({super.key});

  @override
  State<AdminManageScreen> createState() => _AdminManageScreenState();
}

class _AdminManageScreenState extends State<AdminManageScreen> {
  final List<_AdminStory> _stories = [
    _AdminStory(id: '1', title: 'Sangkuriang', category: 'LEGENDA', date: '12 Apr 2026'),
    _AdminStory(id: '2', title: 'Bawang Merah Bawang Putih', category: 'MITOS', date: '10 Apr 2026'),
    _AdminStory(id: '3', title: 'Timun Mas', category: 'FABEL', date: '8 Apr 2026'),
    _AdminStory(id: '4', title: 'Si Kancil', category: 'FABEL', date: '5 Apr 2026'),
    _AdminStory(id: '5', title: 'Roro Jonggrang', category: 'LEGENDA', date: '2 Apr 2026'),
  ];

  Color _catColor(String cat) {
    switch (cat) {
      case 'LEGENDA': return const Color(0xFFBFD9FE);
      case 'MITOS': return const Color(0xFFDDD6FE);
      case 'FABEL': return const Color(0xFFC6F6D5);
      default: return const Color(0xFFE5E7EB);
    }
  }

  Color _catTextColor(String cat) {
    switch (cat) {
      case 'LEGENDA': return const Color(0xFF1D5AA8);
      case 'MITOS': return const Color(0xFF5B21B6);
      case 'FABEL': return const Color(0xFF065F46);
      default: return const Color(0xFF374151);
    }
  }

  void _deleteStory(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Hapus Cerita?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF065F46)),
        ),
        content: Text(
          'Cerita yang dihapus tidak dapat dipulihkan. Lanjutkan?',
          style: GoogleFonts.beVietnamPro(color: const Color(0xFF64655C)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64655C))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _stories.removeWhere((s) => s.id == id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cerita berhasil dihapus.', style: GoogleFonts.plusJakartaSans()),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _editStory(_AdminStory story) {
    final titleCtrl = TextEditingController(text: story.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Edit Cerita',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: const Color(0xFF065F46)),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          child: TextField(
            controller: titleCtrl,
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF373830)),
            decoration: InputDecoration(
              hintText: 'Judul cerita',
              hintStyle: GoogleFonts.beVietnamPro(color: const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64655C))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => story.title = titleCtrl.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cerita berhasil diperbarui!', style: GoogleFonts.plusJakartaSans()),
                  backgroundColor: const Color(0xFF00743B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00743B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Simpan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
                    '${_stories.length} cerita tersedia. Edit atau hapus konten.',
                    style: GoogleFonts.beVietnamPro(fontSize: 14, color: const Color(0xFF64655C)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _stories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_rounded, size: 64, color: Color(0xFFBABAAF)),
                          const SizedBox(height: 12),
                          Text('Belum ada cerita.',
                              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64655C))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                      itemCount: _stories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final story = _stories[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF064E3B).withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Story index badge
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
                              // Story info
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
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _catColor(story.category),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Text(
                                            story.category,
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _catTextColor(story.category),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          story.date,
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
                                    onTap: () => _editStory(story),
                                  ),
                                  const SizedBox(width: 8),
                                  _ActionButton(
                                    icon: Icons.delete_rounded,
                                    bg: const Color(0xFFFEE2E2),
                                    iconColor: const Color(0xFFDC2626),
                                    onTap: () => _deleteStory(story.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
