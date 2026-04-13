import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'jelajah_screen.dart'; // import StoryModel

class MembacaCeritaScreen extends StatelessWidget {
  final StoryModel story;
  const MembacaCeritaScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: Stack(
        children: [
          // Main - Reading Canvas
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                SizedBox(
                  height: 618,
                  child: Stack(
                    children: [
                      // Story Image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(64),
                            bottomRight: Radius.circular(64),
                          ),
                          image: DecorationImage(
                            image: AssetImage(story.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Top dark gradient
                      Container(
                        height: 128,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Bottom gradient fading to background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFFFEFDF1),
                              const Color(0xFFFEFDF1).withOpacity(0),
                              const Color(0xFFFEFDF1).withOpacity(0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      // Title & tags at bottom of hero
                      Positioned(
                        bottom: 48,
                        left: 32,
                        right: 32,
                        child: Column(
                          children: [
                            Text(
                              story.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -1.2,
                                color: const Color(0xFF373830),
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.5),
                                    offset: const Offset(0, 1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: story.categoryColor,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    story.category,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.7,
                                      color: story.categoryTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_filled, color: Color(0xFF64655C), size: 15),
                                    const SizedBox(width: 4),
                                    Text(
                                      story.readTime,
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64655C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Story Content Padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        story.part1,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                          color: const Color(0xFF373830),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Mid-story illustration Break
                      SizedBox(
                        height: 352,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              right: -16,
                              top: -16,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    color: story.categoryColor.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            Transform.rotate(
                              angle: -0.0174533, // -1 degree
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFABD6FF).withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(48),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    story.imagePath, 
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Blockquote
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFBFAED),
                          border: Border(
                            left: BorderSide(color: Color(0xFF75F39C), width: 8),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(48),
                            bottomRight: Radius.circular(48),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: -10,
                              child: Icon(Icons.format_quote_rounded, color: const Color(0xFF00743B).withOpacity(0.15), size: 64),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  story.quote,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    height: 1.62,
                                    color: const Color(0xFF006633),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  story.quoteAuthor,
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF64655C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                
                // Full-width visual mood breaker
                Container(
                  height: 384,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF064E3B).withOpacity(0.1),
                        blurRadius: 50,
                        offset: const Offset(0, 25),
                        spreadRadius: -12,
                      )
                    ],
                    image: DecorationImage(
                      image: AssetImage(story.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00743B).withOpacity(0.2), 
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        story.part2,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.8,
                          color: const Color(0xFF373830),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Progress Indicator (Growing Vine Style)
                      Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9E9DA),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: 0.35,
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00743B), Color(0xFF75F39C)],
                                    ),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: MediaQuery.of(context).size.width * 0.35 - 32,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7A6200),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'BAGIAN 1 SELESAI',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: const Color(0xFF64655C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Interaction Section
                      Container(
                         padding: const EdgeInsets.all(40),
                         width: double.infinity,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           border: const Border(top: BorderSide(color: Colors.white)),
                           borderRadius: BorderRadius.circular(48),
                           boxShadow: [
                             BoxShadow(
                               color: const Color(0xFF064E3B).withOpacity(0.05),
                               blurRadius: 25,
                               offset: const Offset(0, 20),
                               spreadRadius: -5,
                             ),
                           ],
                         ),
                         child: Column(
                           children: [
                             Text(
                               'Lanjut ke cerita berikutnya?',
                               style: GoogleFonts.plusJakartaSans(
                                 fontSize: 30,
                                 fontWeight: FontWeight.w700,
                                 height: 1.2,
                                 color: const Color(0xFF373830),
                               ),
                               textAlign: TextAlign.center,
                             ),
                             const SizedBox(height: 24),
                             ElevatedButton(
                               onPressed: () {},
                               style: ElevatedButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                 backgroundColor: const Color(0xFF00743B),
                                 foregroundColor: Colors.white,
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(48),
                                 ),
                                 elevation: 10,
                                 shadowColor: const Color(0xFF064E3B).withOpacity(0.5),
                                 minimumSize: const Size(double.infinity, 0),
                               ),
                               child: Text(
                                 'Baca Lanjutan',
                                 style: GoogleFonts.beVietnamPro(
                                   fontSize: 18,
                                   fontWeight: FontWeight.w700,
                                 ),
                               ),
                             ),
                             const SizedBox(height: 16),
                             TextButton(
                               onPressed: () {},
                               style: TextButton.styleFrom(
                                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                 backgroundColor: const Color(0xFFABD6FF),
                                 foregroundColor: const Color(0xFF004B74),
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(48),
                                 ),
                                 minimumSize: const Size(double.infinity, 0),
                               ),
                               child: Text(
                                 'Simpan Cerita',
                                 style: GoogleFonts.beVietnamPro(
                                   fontSize: 18,
                                   fontWeight: FontWeight.w700,
                                 ),
                               ),
                             ),
                           ],
                         ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 48, height: 2, color: const Color(0xFFBABAAF).withOpacity(0.3)),
                    const SizedBox(width: 16),
                    Text(
                      '~ • ~',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64655C).withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 48, height: 2, color: const Color(0xFFBABAAF).withOpacity(0.3)),
                  ],
                ),
                
                const SizedBox(height: 128), // Padding for bottom navbar
              ],
            ),
          ),
          
          // Floating Navigation Controls (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _GlassButton(
                      icon: Icons.text_fields_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _GlassButton(
                      icon: Icons.bookmark_border_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Reading Mode Floating Quick Toolbar (Bottom)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 75,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF022C22).withOpacity(0.2),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ToolbarButton(icon: Icons.skip_previous_rounded, label: 'PREV'),
                        Container(width: 1, height: 32, color: const Color(0xFFBABAAF).withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 24)),
                        const _ToolbarButton(icon: Icons.play_arrow_rounded, label: 'PLAY'),
                        Container(width: 1, height: 32, color: const Color(0xFFBABAAF).withOpacity(0.2), margin: const EdgeInsets.symmetric(horizontal: 24)),
                        const _ToolbarButton(icon: Icons.skip_next_rounded, label: 'NEXT'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(color: const Color(0xFF064E3B).withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 20), spreadRadius: -5),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF065F46), size: 24),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF64655C), size: 22),
        const SizedBox(height: 4),
        Text(
           label,
           style: GoogleFonts.beVietnamPro(
             fontSize: 10,
             fontWeight: FontWeight.w700,
             letterSpacing: -0.5,
             color: const Color(0xFF64655C),
           ),
        ),
      ],
    );
  }
}
