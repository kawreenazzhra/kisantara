import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
              const SizedBox(height: 32),

              // ── Stats Grid ──
              Row(
                children: [
                  _StatCard(
                    icon: Icons.menu_book_rounded,
                    value: '24',
                    label: 'Total Cerita',
                    iconBg: const Color(0xFFC6F6D5),
                    iconColor: const Color(0xFF00743B),
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    icon: Icons.people_rounded,
                    value: '138',
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
                    icon: Icons.favorite_rounded,
                    value: '512',
                    label: 'Total Simpanan',
                    iconBg: const Color(0xFFFFD9D6),
                    iconColor: const Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 16),
                  _StatCard(
                    icon: Icons.visibility_rounded,
                    value: '2.4k',
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
              _ActivityTile(
                icon: Icons.add_circle_rounded,
                iconColor: const Color(0xFF059669),
                title: 'Cerita baru ditambahkan',
                subtitle: '"Roro Jonggrang" — 2 jam lalu',
              ),
              _ActivityTile(
                icon: Icons.edit_rounded,
                iconColor: const Color(0xFF2563EB),
                title: 'Cerita diedit',
                subtitle: '"Sangkuriang" — 1 hari lalu',
              ),
              _ActivityTile(
                icon: Icons.delete_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'Cerita dihapus',
                subtitle: '"Malin Kundang (draft)" — 2 hari lalu',
              ),
              _ActivityTile(
                icon: Icons.person_add_rounded,
                iconColor: const Color(0xFF7C3AED),
                title: 'Pengguna baru mendaftar',
                subtitle: 'dewi_cerita@mail.com — 3 hari lalu',
              ),
            ],
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
