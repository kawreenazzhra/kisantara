import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/localization.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFDF1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF064E3B),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.translate('bantuan'),
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
                        color: const Color(0xFF064E3B).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.translate('cari_bantuan'),
                      hintStyle: GoogleFonts.beVietnamPro(
                        color: const Color(0xFFB4B4B4),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF00743B),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  AppLocalizations.translate('pertanyaan_populer'),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF064E3B),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFaqItem(
                  AppLocalizations.translate('faq_q1'),
                  AppLocalizations.translate('faq_a1'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q2'),
                  AppLocalizations.translate('faq_a2'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q3'),
                  AppLocalizations.translate('faq_a3'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q4'),
                  AppLocalizations.translate('faq_a4'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q5'),
                  AppLocalizations.translate('faq_a5'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q6'),
                  AppLocalizations.translate('faq_a6'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q7'),
                  AppLocalizations.translate('faq_a7'),
                ),
                _buildFaqItem(
                  AppLocalizations.translate('faq_q8'),
                  AppLocalizations.translate('faq_a8'),
                ),
              ],
            ),
          ),
        );
      },
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
            color: const Color(0xFF064E3B).withValues(alpha: 0.05),
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

}

