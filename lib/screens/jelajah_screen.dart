import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'membaca_cerita_screen.dart';

class StoryModel {
  final String title;
  final String subtitle;
  final String imagePath;
  final String category;
  final Color categoryColor;
  final Color categoryTextColor;
  
  // Dynamic story content fields
  final String readTime;
  final String part1;
  final String quote;
  final String quoteAuthor;
  final String part2;

  const StoryModel({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.category,
    this.categoryColor = const Color(0xFFFED023),
    this.categoryTextColor = const Color(0xFF594700),
    required this.readTime,
    required this.part1,
    required this.quote,
    required this.quoteAuthor,
    required this.part2,
  });
}

final List<StoryModel> appStories = [
  StoryModel(
    title: 'Sangkuriang',
    subtitle: 'Gunung Tangkuban Perahu',
    imagePath: 'assets/images/sangkuriang.png',
    category: 'LEGENDA',
    readTime: '6 min baca',
    part1: 'Di sebuah hutan lebat, hiduplah seorang putri cantik bernama Dayang Sumbi dan putranya, Sangkuriang. Suatu hari, Sangkuriang tanpa sengaja membunuh Tumang, anjing kesayangan ibunya yang sebenarnya adalah ayah kandungnya sendiri.',
    quote: '"Pergilah kau, anak durhaka! Jangan pernah kembali sampai kau mengerti kesalahanmu!"',
    quoteAuthor: '— Dayang Sumbi',
    part2: 'Bertahun-tahun berlalu, Sangkuriang kembali ke desanya dan tak mengenali ibunya yang masih tampak muda. Ia jatuh cinta pada Dayang Sumbi, yang kemudian memberinya syarat mustahil: membuat danau dan perahu dalam semalam.',
  ),
  StoryModel(
    title: 'Bawang Merah Bawang Putih',
    subtitle: 'Kisah Dua Saudara',
    imagePath: 'assets/images/bawang_merah.png',
    category: 'MITOS',
    readTime: '4 min baca',
    part1: 'Bawang Putih adalah gadis yang baik hati namun disiksa oleh ibu dan saudara tirinya, Bawang Merah. Ia harus mengerjakan semua pekerjaan rumah seorang diri tanpa pernah mengeluh.',
    quote: '"Cepat cuci bajuku! Jangan bermalas-malasan, anak tak berguna!"',
    quoteAuthor: '— Bawang Merah',
    part2: 'Suatu ketika, selendang ibu Bawang Merah hanyut di sungai, mengantarkan Bawang Putih kepada seorang nenek sakti yang memberinya labu berisi emas permata sebagai balasan atas kebaikannya.',
  ),
  StoryModel(
    title: 'Timun Mas',
    subtitle: 'Gadis Timun Emas',
    imagePath: 'assets/images/timun_mas.png',
    category: 'FABEL',
    readTime: '3 min baca',
    part1: 'Di sebuah desa kecil, hiduplah seorang janda bernama Mbok Sirni. Ia hidup sebatang kara dan sangat mendambakan kehadiran seorang anak. Suatu hari, Buto Ijo mendengarnya berdoa.',
    quote: '"Jangan takut, Mbok Sirni. Tanamlah biji ini, kau akan mendapatkan apa yang kau inginkan."',
    quoteAuthor: '— Suara Gema Buto Ijo',
    part2: 'Mbok Sirni menanam biji itu, dan tumbuhlah mentimun emas besar. Ketika dibelah, terdapat bayi cantik bernama Timun Mas. Namun, Buto Ijo kelak menagih janjinya untuk memakan anak itu.',
  ),
  StoryModel(
    title: 'Si Kancil',
    subtitle: 'Kancil dan Buaya',
    imagePath: 'assets/images/si_kancil.png',
    category: 'FABEL',
    readTime: '2 min baca',
    part1: 'Di suatu pagi yang cerah, udara terasa sangat segar karena semalam baru saja turun hujan. Si Kancil yang cerdik berjalan-jalan santai mencari makanan di tepi sungai yang sedang pasang.',
    quote: '"Hai buaya, menepi sebentar! Aku punya pesan penting dari Raja Sulaiman untuk menghitung kalian!"',
    quoteAuthor: '— Kancil yang cerdik',
    part2: 'Buaya-buaya yang percaya pun berbaris rapi dari tepi satu ke tepi lainnya. Dengan cerdiknya, kancil melompat ke punggung buaya sambil berhitung, lalu berhasil melarikan diri menyeberang sungai.',
  ),
];

final List<String> _categories = ['Semua', 'Mitos', 'Legenda', 'Fabel'];

class JelajahScreen extends StatefulWidget {
  const JelajahScreen({super.key});

  @override
  State<JelajahScreen> createState() => _JelajahScreenState();
}

class _JelajahScreenState extends State<JelajahScreen> {
  int _selectedCategory = 0;

  List<StoryModel> get _filtered {
    if (_selectedCategory == 0) return appStories;
    final cat = _categories[_selectedCategory].toUpperCase();
    return appStories.where((s) => s.category == cat).toList();
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
          CustomScrollView(
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
                // Stories grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 159 / 290,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final story = _filtered[i];
                        final isRightColumn = i % 2 == 1;
                        return Padding(
                          padding: EdgeInsets.only(top: isRightColumn ? 32 : 0),
                          child: _StoryCard(story: story),
                        );
                      },
                      childCount: _filtered.length,
                    ),
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
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFE0),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search, color: const Color(0xFF00743B).withOpacity(0.6), size: 22),
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
    );
  }
}

// ─────────────────────────────────────────────
// Category Chips
// ─────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selected;
  final ValueChanged<int> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categories.length, (i) {
          final isActive = i == selected;
          return Padding(
            padding: EdgeInsets.only(right: i < categories.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00743B)
                      : const Color(0xFFABD6FF),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00743B).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: const Color(0xFF00743B).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  categories[i],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF004B74),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Story Card
// ─────────────────────────────────────────────
class _StoryCard extends StatelessWidget {
  final StoryModel story;
  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MembacaCeritaScreen(story: story),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Image with category badge
        Stack(
          children: [
            Container(
              height: 212,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: -12,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.asset(
                  story.imagePath,
                  width: double.infinity,
                  height: 212,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Category badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: story.categoryColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  story.category,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: story.categoryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        // Title + subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF373830),
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                story.subtitle,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64655C),
                  height: 1.43,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
