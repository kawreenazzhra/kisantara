import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF75F39C), width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
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
                    child: const Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Penjelajah Kisantara',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'penjelajah@kisantara.id',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: const Color(0xFF64655C),
                ),
              ),
              const SizedBox(height: 40),
              // Stats row
              Row(
                children: [
                  _StatCard(value: '12', label: 'Cerita Dibaca'),
                  const SizedBox(width: 16),
                  _StatCard(value: '3', label: 'Lencana'),
                  const SizedBox(width: 16),
                  _StatCard(value: '5', label: 'Disimpan'),
                ],
              ),
              const SizedBox(height: 32),
              // Menu items
              _MenuItem(
                  icon: Icons.person_rounded, label: 'Edit Profil', context: context),
              _MenuItem(
                  icon: Icons.notifications_rounded, label: 'Notifikasi', context: context),
              _MenuItem(
                  icon: Icons.language_rounded, label: 'Bahasa', context: context),
              _MenuItem(
                  icon: Icons.help_outline_rounded, label: 'Bantuan', context: context),
              const SizedBox(height: 16),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Anda telah keluar dari aplikasi.', style: GoogleFonts.plusJakartaSans()),
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFDC2626)),
                  label: Text(
                    'Keluar',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                        color: Color(0xFFDC2626), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(48)),
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

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF75F39C).withOpacity(0.15),
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
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;
  const _MenuItem({required this.icon, required this.label, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF75F39C).withOpacity(0.2),
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
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF64655C)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka menu $label...', style: GoogleFonts.plusJakartaSans()),
              backgroundColor: const Color(0xFF00743B),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
