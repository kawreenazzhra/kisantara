import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'membaca_cerita_screen.dart';
import '../services/database_service.dart';
import '../models/story_model.dart';

final List<String> _categories = ['Semua', 'Mitos', 'Legenda', 'Fabel'];

class JelajahScreen extends StatefulWidget {
  const JelajahScreen({super.key});

  @override
  State<JelajahScreen> createState() => _JelajahScreenState();
}

class _JelajahScreenState extends State<JelajahScreen> {
  int _selectedCategory = 0;
  final DatabaseService _databaseService = DatabaseService();

  List<StoryModel> _filterStories(List<StoryModel> stories) {
    if (_selectedCategory == 0) return stories;
    final cat = _categories[_selectedCategory].toUpperCase();
    return stories.where((s) => s.category.toUpperCase() == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: Stack(
        children: [
          // Background radial gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7071,
                colors: [Color(0xFFE9E9DA), Color(0xFFFEFDF1)],
                stops: [0.0148, 0.0148],
              ),
            ),
          ),
          StreamBuilder<List<StoryModel>>(
            stream: _databaseService.getStories(),
            builder: (context, snapshot) {
              final stories = snapshot.data ?? [];
              final filtered = _filterStories(stories);

              return CustomScrollView(
                slivers: [
                  // Spacer: status bar + top app bar (72dp) + breathing room
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 72 + 24,
                    ),
                  ),
                  // Search + Filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SearchBar(),
                          const SizedBox(height: 24),
                          _CategoryChips(
                            categories: _categories,
                            selected: _selectedCategory,
                            onSelected: (i) =>
                                setState(() => _selectedCategory = i),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF00743B)),
                      ),
                    )
                  else if (filtered.isEmpty)
                     SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_rounded, size: 64, color: Color(0xFFBABAAF)),
                            const SizedBox(height: 12),
                            Text('Belum ada cerita.',
                                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64655C))),
                          ],
                        ),
                      ),
                    )
                  else
                    // Stories grid (Masonry Layout)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        itemBuilder: (ctx, i) {
                          final story = filtered[i];
                          return _StoryCard(story: story, index: i);
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  // Reading Mission card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _MissionCard(),
                    ),
                  ),
                  // Bottom nav padding
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          ),
          // Top App Bar
          _TopAppBar(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Search Bar
// ─────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(48),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00743B).withOpacity(_isPressed ? 0.08 : 0.04),
                blurRadius: _isPressed ? 24 : 16,
                spreadRadius: _isPressed ? 2 : 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Icon(
                Icons.search,
                color: const Color(0xFF00743B).withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Cari cerita ajaib...',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64655C).withOpacity(0.5),
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

// ─────────────────────────────────────────────
// Category Chips
// ─────────────────────────────────────────────
class _CategoryChips extends StatefulWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  final ScrollController _scrollController = ScrollController();
  double _scrollVelocity = 0.0;
  double _lastOffset = 0.0;
  int _lastTimestamp = DateTime.now().microsecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!mounted) return;
    final now = DateTime.now().microsecondsSinceEpoch;
    final double currentOffset = _scrollController.offset;
    final int dt = now - _lastTimestamp; // in microseconds
    if (dt > 0) {
      final double delta = currentOffset - _lastOffset;
      // velocity is px per microsecond * 1000
      final double velocity = (delta / dt) * 1000.0;
      setState(() {
        _scrollVelocity = velocity.clamp(-15.0, 15.0);
      });
    }
    _lastOffset = currentOffset;
    _lastTimestamp = now;

    // Decay velocity back to 0
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      if (_scrollController.offset == _lastOffset) {
        setState(() {
          _scrollVelocity = _scrollVelocity * 0.7;
          if (_scrollVelocity.abs() < 0.1) _scrollVelocity = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(widget.categories.length, (i) {
          final isActive = i == widget.selected;
          return Padding(
            padding: EdgeInsets.only(right: i < widget.categories.length - 1 ? 12 : 0),
            child: Transform(
              transform: Matrix4.skewX(_scrollVelocity * 0.015),
              alignment: Alignment.center,
              child: _InteractiveCategoryChip(
                label: widget.categories[i],
                isActive: isActive,
                onTap: () => widget.onSelected(i),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _InteractiveCategoryChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _InteractiveCategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_InteractiveCategoryChip> createState() => _InteractiveCategoryChipState();
}

class _InteractiveCategoryChipState extends State<_InteractiveCategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF00743B)
                : const Color(0xFFABD6FF),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: widget.isActive ? Colors.transparent : Colors.white.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00743B).withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF00743B).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFFABD6FF).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w600,
              color: widget.isActive
                  ? Colors.white
                  : const Color(0xFF004B74),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Story Card
// ─────────────────────────────────────────────
class _StoryCard extends StatefulWidget {
  final StoryModel story;
  final int index;
  const _StoryCard({required this.story, required this.index});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double imageHeight = widget.index % 3 == 0
        ? 190.0
        : (widget.index % 3 == 1 ? 240.0 : 215.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MembacaCeritaScreen(story: widget.story),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with category badge
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF064E3B).withOpacity(0.08),
                        blurRadius: 40,
                        spreadRadius: -8,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: widget.story.imagePath.startsWith('http')
                        ? Image.network(
                            widget.story.imagePath,
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(Icons.image_not_supported_rounded),
                                ),
                          )
                        : Image.asset(
                            widget.story.imagePath,
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.story.categoryColor,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      widget.story.category,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: widget.story.categoryTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title + subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.story.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF373830),
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.story.subtitle,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64655C),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mission Card
// ─────────────────────────────────────────────
class _MissionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(48),
      child: Stack(
        children: [
          // Decorative blurred circle
          Positioned(
            right: -32,
            bottom: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFF00743B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF75F39C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Misi Membaca',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selesaikan 2 cerita lagi untuk lencana baru!',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF065F46).withOpacity(0.7),
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    // Fill (65% progress)
                    FractionallySizedBox(
                      widthFactor: 0.65,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00743B),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.65 - 90,
                      top: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A6200),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Top App Bar
// ─────────────────────────────────────────────
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF064E3B).withOpacity(0.05),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: hamburger + brand name
                Row(
                  children: [
                    Icon(Icons.menu_rounded,
                        color: const Color(0xFF047857), size: 24),
                    const SizedBox(width: 16),
                    Text(
                      'Kisantara',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                // Right: avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF75F39C),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/user_avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
