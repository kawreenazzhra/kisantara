import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFDF1),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF064E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bantuan',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF064E3B),
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari bantuan...',
                  hintStyle: GoogleFonts.beVietnamPro(color: const Color(0xFFB4B4B4)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00743B)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Pertanyaan Populer',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF064E3B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            _buildFaqItem(
              'Bagaimana cara menyimpan cerita?',
              'Ketuk ikon "Simpan" di pojok kanan atas saat membaca cerita untuk menyimpannya ke daftar pustaka kamu.',
            ),
            _buildFaqItem(
              'Apakah aplikasi ini gratis?',
              'Ya! Kisantara berkomitmen untuk menyebarkan kekayaan budaya nusantara secara gratis untuk semua anak Indonesia.',
            ),
            _buildFaqItem(
              'Cara mendapatkan lencana baru?',
              'Selesaikan misi membaca dan jelajahi berbagai kategori cerita untuk membuka lencana-lencana unik.',
            ),
            _buildFaqItem(
              'Cerita saya tidak bisa dimuat?',
              'Pastikan koneksi internet kamu stabil, atau bersihkan cache aplikasi di pengaturan profil.',
            ),

            const SizedBox(height: 48),
            
            // Contact Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF75F39C).withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF75F39C).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 48, color: Color(0xFF00743B)),
                  const SizedBox(height: 16),
                  Text(
                    'Masih butuh bantuan?',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF064E3B),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tim kami siap membantu masalah yang kamu hadapi.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      color: const Color(0xFF064E3B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.chat_rounded,
                          label: 'Chat',
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF373830),
            fontSize: 14,
          ),
        ),
        iconColor: const Color(0xFF00743B),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            answer,
            style: GoogleFonts.beVietnamPro(
              color: const Color(0xFF64655C),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00743B),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
