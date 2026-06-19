import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/translation_script.dart';
import '../profile/notifikasi_screen.dart';
import '../../services/notification_service.dart';

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
  int _totalRead = 0;
  int _pendingStories = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _storiesSubscription;
  StreamSubscription? _usersSubscription;
  bool _hasStoriesData = false;
  bool _hasUsersData = false;

  @override
  void initState() {
    super.initState();
    _subscribeToStats();
  }

  void _subscribeToStats() {
    _storiesSubscription = _db
        .collection('stories')
        .snapshots()
        .listen((storiesSnapshot) {
      int approvedCount = 0;
      int pendingCount = 0;
      List<DocumentSnapshot<Map<String, dynamic>>> approvedDocs = [];

      for (var doc in storiesSnapshot.docs) {
        final data = doc.data();
        final originalId = data['originalId'] ?? '';
        if (originalId.toString().isNotEmpty) continue; // Skip translation duplicates

        final status = data['status'] ?? 'approved';
        if (status == 'approved') {
          approvedCount++;
          approvedDocs.add(doc);
        } else if (status == 'pending') {
          pendingCount++;
        }
      }

      // Sort recent stories by timestamp descending
      approvedDocs.sort((a, b) {
        final aTime = (a.data()?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = (b.data()?['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      final recentStories = approvedDocs.take(5).toList();
      List<Map<String, dynamic>> activities = [];
      for (var storyDoc in recentStories) {
        final data = storyDoc.data();
        if (data != null) {
          final title = data['title'] ?? 'Cerita Tanpa Judul';
          final author = data['authorName'] ?? 'Anonim';
          activities.add({
            'icon': Icons.add_circle_rounded,
            'iconColor': const Color(0xFF059669),
            'title': 'Cerita dipublikasikan',
            'subtitle': '"$title" oleh $author',
          });
        }
      }

      if (mounted) {
        setState(() {
          _totalStories = approvedCount;
          _pendingStories = pendingCount;
          _recentActivities = activities;
          _hasStoriesData = true;
          if (_hasUsersData) {
            _isLoading = false;
          }
        });
      }
    }, onError: (e) {
      print('Dashboard error (stories stream): $e');
    });

    _usersSubscription = _db
        .collection('users')
        .snapshots()
        .listen((usersSnapshot) {
      int usersCount = usersSnapshot.docs.length;
      int readCount = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final read = data['recentlyRead'] as List?;
        readCount += read?.length ?? 0;
      }

      if (mounted) {
        setState(() {
          _totalUsers = usersCount;
          _totalRead = readCount;
          _hasUsersData = true;
          if (_hasStoriesData) {
            _isLoading = false;
          }
        });
      }
    }, onError: (e) {
      print('Dashboard error (users stream): $e');
    });
  }

  Future<void> _handleRefresh() async {
    _storiesSubscription?.cancel();
    _usersSubscription?.cancel();
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasStoriesData = false;
        _hasUsersData = false;
      });
    }
    _subscribeToStats();
    
    // Wait for data load or max 2 seconds to close refresh indicator
    int counter = 0;
    while (_isLoading && counter < 20 && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      counter++;
    }
  }

  @override
  void dispose() {
    _storiesSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
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
                    Row(
                      children: [
                        StreamBuilder<int>(
                          stream: _notificationService.getUnreadNotificationsCount(),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            return Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_rounded,
                                    color: Color(0xFF00743B),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NotifikasiScreen(),
                                      ),
                                    );
                                  },
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 8,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.translate_rounded,
                            color: Color(0xFF00743B),
                          ),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menjalankan script terjemahan...')),
                            );
                            await TranslationScript.runAutomatedTranslation();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Terjemahan selesai!')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Color(0xFF00743B),
                          ),
                          onPressed: _handleRefresh,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF00743B),
                      ),
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
                          style: GoogleFonts.beVietnamPro(
                            color: const Color(0xFFBABAAF),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentActivities.map(
                      (act) => _ActivityTile(
                        icon: act['icon'],
                        iconColor: act['iconColor'],
                        title: act['title'],
                        subtitle: act['subtitle'],
                      ),
                    ),
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
              color: const Color(0xFF064E3B).withValues(alpha: 0.05),
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
            color: const Color(0xFF064E3B).withValues(alpha: 0.04),
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
              color: iconColor.withValues(alpha: 0.1),
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
