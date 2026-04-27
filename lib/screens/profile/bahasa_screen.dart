import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BahasaScreen extends StatefulWidget {
  const BahasaScreen({super.key});

  @override
  State<BahasaScreen> createState() => _BahasaScreenState();
}

class _BahasaScreenState extends State<BahasaScreen> {
  String _selectedLanguage = 'Bahasa Indonesia';

  final List<Map<String, String>> _languages = [
    {'name': 'Bahasa Indonesia', 'code': 'ID', 'flag': '🇮🇩'},
    {'name': 'English', 'code': 'EN', 'flag': '🇺🇸'},
    {'name': 'Jawa', 'code': 'JV', 'flag': '🏺'},
    {'name': 'Sunda', 'code': 'SU', 'flag': '🏺'},
  ];

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
          'Pilih Bahasa',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF064E3B),
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _languages.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selectedLanguage == lang['name'];

          return GestureDetector(
            onTap: () => setState(() => _selectedLanguage = lang['name']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00743B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isSelected
                    ? Border.all(color: const Color(0xFF75F39C), width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: Row(
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang['name']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF373830),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          lang['code']!,
                          style: GoogleFonts.beVietnamPro(
                            color: isSelected ? Colors.white70 : const Color(0xFF64655C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: Colors.white)
                  else
                    const Icon(Icons.radio_button_off_rounded, color: Color(0xFF64655C)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bahasa berhasil diubah ke $_selectedLanguage!', style: GoogleFonts.plusJakartaSans()),
                  backgroundColor: const Color(0xFF00743B),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00743B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Gunakan Bahasa Ini',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
