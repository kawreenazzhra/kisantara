import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CeritaSayaScreen extends StatelessWidget {
  const CeritaSayaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
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
            ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF75F39C).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_rounded,
                          color: Color(0xFF00743B), size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum ada cerita tersimpan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF373830),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simpan cerita favorit kamu\ndi halaman Jelajah!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        color: const Color(0xFF64655C),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
