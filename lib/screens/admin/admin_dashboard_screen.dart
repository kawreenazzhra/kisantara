import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  int _totalStories = 0;
  int _totalUsers = 0;
  int _totalSaved = 0;
  int _totalRead = 0;
  int _pendingStories = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    int storiesCount = 0;
    int pendingCount = 0;
    int usersCount = 0;
    int savedCount = 0;
    int readCount = 0;
    List<Map<String, dynamic>> activities = [];

    // 1. Stories (approved)
    try {
      final storiesSnapshot = await _db
          .collection('stories')
          .where('status', isEqualTo: 'approved')
          .orderBy('timestamp', descending: true)
          .get();
      storiesCount = storiesSnapshot.docs.length;
      final recentStories = storiesSnapshot.docs.take(5).toList();
      for (var storyDoc in recentStories) {
        final data = storyDoc.data();
        final title = data['title'] ?? 'Cerita Tanpa Judul';
        final author = data['authorName'] ?? 'Anonim';
        activities.add({
          'icon': Icons.add_circle_rounded,
          'iconColor': const Color(0xFF059669),
          'title': 'Cerita dipublikasikan',
          'subtitle': '"$title" oleh $author',
        });
      }
    } catch (e) {
      print('Dashboard error (stories): $e');
      // Keep storiesCount = 0; show real data only
    }

    // 2. Pending stories
    try {
      final pendingSnapshot = await _db
          .collection('stories')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingCount = pendingSnapshot.docs.length;
    } catch (e) {
      print('Dashboard error (pending): $e');
    }

    // 3. Users
    try {
      final usersSnapshot = await _db.collection('users').get();
      usersCount = usersSnapshot.docs.length;
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final saved = data['savedStories'] as List?;
        final read = data['recentlyRead'] as List?;
        savedCount += saved?.length ?? 0;
        readCount += read?.length ?? 0;
      }
    } catch (e) {
      print('Dashboard error (users): $e');
    }

    if (mounted) {
      setState(() {
        _totalStories = storiesCount;
        _pendingStories = pendingCount;
        _totalUsers = usersCount;
        _totalSaved = savedCount;
        _totalRead = readCount;
        _recentActivities = activities;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: const Color(0xFF00743B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dasbor Admin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF065F46),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pantau aktivitas & konten Kisantara.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            color: const Color(0xFF64655C),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF00743B)),
                      onPressed: _loadStats,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Color(0xFF00743B)),
                    ),
                  )
                else ...[
                  // ── Stats Grid ──
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.menu_book_rounded,
                        value: '$_totalStories',
                        label: 'Total Cerita',
                        iconBg: const Color(0xFFC6F6D5),
                        iconColor: const Color(0xFF00743B),
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        icon: Icons.people_rounded,
                        value: '$_totalUsers',
                        label: 'Pengguna',
                        iconBg: const Color(0xFFBFD9FE),
                        iconColor: const Color(0xFF1D5AA8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.pending_rounded,
                        value: '$_pendingStories',
                        label: 'Menunggu Validasi',
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        icon: Icons.visibility_rounded,
                        value: '$_totalRead',
                        label: 'Total Dibaca',
                        iconBg: const Color(0xFFFEF08A),
                        iconColor: const Color(0xFF7A6200),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Recent Activity ──
                  Text(
                    'Aktivitas Terbaru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_recentActivities.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Belum ada aktivitas penulisan cerita.',
                          style: GoogleFonts.beVietnamPro(color: const Color(0xFFBABAAF)),
                        ),
                      ),
                    )
                  else
                    ..._recentActivities.map((act) => _ActivityTile(
                          icon: act['icon'],
                          iconColor: act['iconColor'],
                          title: act['title'],
                          subtitle: act['subtitle'],
                        )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064E3B).withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF373830),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: const Color(0xFF64655C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF373830),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: const Color(0xFF64655C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
