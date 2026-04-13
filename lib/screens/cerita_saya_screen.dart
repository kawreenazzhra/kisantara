import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jelajah_screen.dart'; 
import 'membaca_cerita_screen.dart';

class CeritaSayaScreen extends StatefulWidget {
  const CeritaSayaScreen({super.key});

  @override
  State<CeritaSayaScreen> createState() => _CeritaSayaScreenState();
}

class _CeritaSayaScreenState extends State<CeritaSayaScreen> {
  int _selectedTab = 0; // 0 = Disimpan, 1 = Terakhir Dibaca

  @override
  Widget build(BuildContext context) {
    // Determine which stories to show based on dummy state
    final listToShow = _selectedTab == 0
        ? [appStories[1], appStories[2]] // Saved: Bawang Merah, Timun Mas
        : [appStories[0], appStories[3]]; // Terakhir Dibaca: Sangkuriang, Si Kancil

    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
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
              child: Row(
                children: [
                  _TabItem(
                    title: 'Disimpan',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 16),
                  _TabItem(
                    title: 'Terakhir Dibaca',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List of Stories
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                itemCount: listToShow.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final story = listToShow[index];
                  return _StoryListTile(story: story);
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
            color: isSelected ? const Color(0xFF00743B) : const Color(0xFFBABAAF).withOpacity(0.5),
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
  const _StoryListTile({required this.story});

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF064E3B).withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                story.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF64655C)),
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBABAAF)),
          ],
        ),
      ),
    );
  }
}
