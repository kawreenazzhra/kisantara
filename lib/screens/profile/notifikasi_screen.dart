import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _newStoryPush = true;
  bool _newStoryEmail = false;
  bool _updatePush = true;
  bool _promoPush = false;
  bool _securityPush = true;

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
          'Notifikasi',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF064E3B),
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('Cerita Baru'),
          _buildSwitchTile(
            title: 'Push Notification',
            subtitle: 'Dapatkan kabar saat ada cerita nusantara baru.',
            value: _newStoryPush,
            onChanged: (val) => setState(() => _newStoryPush = val),
          ),
          _buildSwitchTile(
            title: 'Email',
            subtitle: 'Ringkasan cerita baru lewat kotak masukmu.',
            value: _newStoryEmail,
            onChanged: (val) => setState(() => _newStoryEmail = val),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Pembaruan & Promo'),
          _buildSwitchTile(
            title: 'Pembaruan Aplikasi',
            subtitle: 'Info fitur baru dan perbaikan sistem.',
            value: _updatePush,
            onChanged: (val) => setState(() => _updatePush = val),
          ),
          _buildSwitchTile(
            title: 'Promosi & Event',
            subtitle: 'Info acara spesial dan penawaran menarik.',
            value: _promoPush,
            onChanged: (val) => setState(() => _promoPush = val),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Keamanan'),
          _buildSwitchTile(
            title: 'Keamanan Akun',
            subtitle: 'Pemberitahuan login atau perubahan sandi.',
            value: _securityPush,
            onChanged: (val) => setState(() => _securityPush = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF064E3B),
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        activeColor: const Color(0xFF00743B),
        activeTrackColor: const Color(0xFF75F39C).withOpacity(0.3),
        inactiveThumbColor: const Color(0xFFB4B4B4),
        inactiveTrackColor: const Color(0xFFE5E7EB),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF373830),
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.beVietnamPro(
            color: const Color(0xFF64655C),
            fontSize: 12,
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}
