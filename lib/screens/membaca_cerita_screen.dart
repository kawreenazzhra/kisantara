import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/localization.dart';

class MembacaCeritaScreen extends StatefulWidget {
  final StoryModel story;
  const MembacaCeritaScreen({super.key, required this.story});

  @override
  State<MembacaCeritaScreen> createState() => _MembacaCeritaScreenState();
}

class _MembacaCeritaScreenState extends State<MembacaCeritaScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _recordRecentRead();
    _loadScrollPosition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final offset = prefs.getDouble('scroll_${widget.story.canonicalId}') ?? 0.0;
    if (offset > 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(offset);
        }
      });
    }
  }

  void _saveScrollPosition(double offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scroll_${widget.story.canonicalId}', offset);
  }

  void _recordRecentRead() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.addToRecentlyRead(user.uid, widget.story);
    }
  }

  void _toggleBookmark() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isCurrentlyBookmarked = await _databaseService.isStoryBookmarked(user.uid, widget.story).first;
      await _databaseService.toggleBookmark(user.uid, widget.story);
      if (mounted) {
        final snackBarText = isCurrentlyBookmarked
            ? AppLocalizations.translate('batal_menyimpan_cerita_notif')
            : AppLocalizations.translate('berhasil_menyimpan_cerita_notif');

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              snackBarText,
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF00743B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.currentLanguageNotifier,
      builder: (context, currentLanguage, _) {
        return StreamBuilder<StoryModel>(
          stream: _databaseService.getStoryByCanonicalIdStream(
            widget.story.canonicalId,
            fallbackStory: widget.story,
            language: currentLanguage,
          ),
          initialData: widget.story,
          builder: (context, snapshot) {
            final story = snapshot.data ?? widget.story;
            return Scaffold(
          backgroundColor: const Color(0xFFFEFDF1),
          body: Stack(
            children: [
              // Main - Reading Canvas
              NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical) {
                    _saveScrollPosition(_scrollController.offset);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                                  image: story.imagePath.startsWith('http')
                                      ? NetworkImage(story.imagePath)
                                            as ImageProvider
                                      : AssetImage(story.imagePath),
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
                                    Colors.black.withValues(alpha: 0.4),
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
                                    const Color(0xFFFEFDF1).withValues(alpha: 0),
                                    const Color(0xFFFEFDF1).withValues(alpha: 0),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: story.categoryColor,
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          AppLocalizations.translate(story.category.toLowerCase()).toUpperCase(),
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
                                          const Icon(
                                            Icons.access_time_filled,
                                            color: Color(0xFF64655C),
                                            size: 15,
                                          ),
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
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 32,
                                        sigmaY: 32,
                                      ),
                                      child: Container(
                                        width: 128,
                                        height: 128,
                                        decoration: BoxDecoration(
                                          color: story.categoryColor.withValues(
                                            alpha: 0.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFABD6FF,
                                      ).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(48),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: story.imagePath.startsWith('http')
                                          ? Image.network(
                                              story.imagePath,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons
                                                        .image_not_supported_rounded,
                                                    size: 50,
                                                  ),
                                            )
                                          : Image.asset(
                                              story.imagePath,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (story.quote.trim().isNotEmpty) ...[
                              const SizedBox(height: 48),
                              // Blockquote
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFBFAED),
                                  border: Border(
                                    left: BorderSide(
                                      color: Color(0xFF75F39C),
                                      width: 8,
                                    ),
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
                                      child: Icon(
                                        Icons.format_quote_rounded,
                                        color: const Color(
                                          0xFF00743B,
                                        ).withValues(alpha: 0.15),
                                        size: 64,
                                      ),
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
                            ],
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
                              color: const Color(0xFF064E3B).withValues(alpha: 0.1),
                              blurRadius: 50,
                              offset: const Offset(0, 25),
                              spreadRadius: -12,
                            ),
                          ],
                          image: DecorationImage(
                            image: story.imagePath.startsWith('http')
                                ? NetworkImage(story.imagePath) as ImageProvider
                                : AssetImage(story.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00743B).withValues(alpha: 0.2),
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
                            // Interaction Section
                            Container(
                              padding: const EdgeInsets.all(40),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: const Border(
                                  top: BorderSide(color: Colors.white),
                                ),
                                borderRadius: BorderRadius.circular(48),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF064E3B,
                                    ).withValues(alpha: 0.05),
                                    blurRadius: 25,
                                    offset: const Offset(0, 20),
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.translate('bagaimana_ceritanya'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                      color: const Color(0xFF373830),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  if (user != null)
                                    StreamBuilder<bool>(
                                      stream: _databaseService.isStoryBookmarked(
                                        user.uid,
                                        story,
                                      ),
                                      builder: (context, snapshot) {
                                        final isBookmarked = snapshot.data ?? false;
                                        return TextButton.icon(
                                          onPressed: _toggleBookmark,
                                          icon: Icon(
                                            isBookmarked
                                                ? Icons.bookmark_rounded
                                                : Icons.bookmark_border_rounded,
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 40,
                                              vertical: 20,
                                            ),
                                            backgroundColor: isBookmarked
                                                ? const Color(0xFFFEE2E2)
                                                : const Color(0xFFABD6FF),
                                            foregroundColor: isBookmarked
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF004B74),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                48,
                                              ),
                                            ),
                                            minimumSize: const Size(
                                              double.infinity,
                                              0,
                                            ),
                                          ),
                                          label: Text(
                                            isBookmarked
                                                ? AppLocalizations.translate('batal_simpan_cerita')
                                                : AppLocalizations.translate('simpan_cerita_ini'),
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  else
                                    TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.bookmark_border_rounded,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 20,
                                        ),
                                        backgroundColor: const Color(0xFFABD6FF),
                                        foregroundColor: const Color(0xFF004B74),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(48),
                                        ),
                                        minimumSize: const Size(double.infinity, 0),
                                      ),
                                      label: Text(
                                        AppLocalizations.translate('simpan_cerita_ini'),
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
                          Container(
                            width: 48,
                            height: 2,
                            color: const Color(0xFFBABAAF).withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '~ • ~',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64655C).withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 48,
                            height: 2,
                            color: const Color(0xFFBABAAF).withValues(alpha: 0.3),
                          ),
                        ],
                      ),

                      const SizedBox(height: 128), // Padding for bottom navbar
                    ],
                  ),
                ),
              ), // Closing NotificationListener
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
                        if (user != null)
                          StreamBuilder<bool>(
                            stream: _databaseService.isStoryBookmarked(
                              user.uid,
                              story,
                            ),
                            builder: (context, snapshot) {
                              final isBookmarked = snapshot.data ?? false;
                              return _GlassButton(
                                icon: isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                onTap: _toggleBookmark,
                              );
                            },
                          )
                        else
                          _GlassButton(
                            icon: Icons.bookmark_border_rounded,
                            onTap: () {},
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
          },
        );
      },
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
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 20),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF065F46), size: 24),
          ),
        ),
      ),
    );
  }
}
