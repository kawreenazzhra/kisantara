import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/content_filter_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../models/story_model.dart';

class WriteStoryScreen extends StatefulWidget {
  final StoryModel? editStory; // Optional, in case they want to edit their story

  const WriteStoryScreen({super.key, this.editStory});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _quoteController = TextEditingController();
  final _quoteAuthorController = TextEditingController();
  final _part1Controller = TextEditingController();
  final _part2Controller = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'LEGENDA';
  String? _simulatedImageName;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  bool _showQuote = false; // Kutipan opsional
  String _authorName = 'Anonim';

  final List<String> _categories = ['LEGENDA', 'MITOS', 'FABEL'];
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // If editing, fill fields
    if (widget.editStory != null) {
      final story = widget.editStory!;
      _titleController.text = story.title;
      _subtitleController.text = story.subtitle;
      _quoteController.text = story.quote;
      _quoteAuthorController.text = story.quoteAuthor;
      _part1Controller.text = story.part1;
      _part2Controller.text = story.part2;
      
      if (story.imagePath.startsWith('http')) {
        _imageUrlController.text = story.imagePath;
        _uploadedImageUrl = story.imagePath;
      } else {
        _simulatedImageName = story.imagePath.split('/').last;
      }
      _selectedCategory = story.category.toUpperCase();
    }
  }

  void _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (profile != null) {
        setState(() {
          _authorName = profile.penName;
        });
      }
    }
  }

  void _pickAndUpload() async {
    setState(() => _isLoading = true);
    try {
      final downloadUrl = await _storageService.pickAndUploadImage();
      if (downloadUrl == null) {
        // User cancelled picker
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _simulatedImageName = 'Gambar diunggah ✓';
        _imageUrlController.text = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gambar berhasil diunggah! 🎉',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF00743B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah gambar: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _generateAICover() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tulis judul cerita terlebih dahulu agar AI tahu apa yang ingin digambar!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final prompt = _storageService.buildSmartPrompt(title, _selectedCategory);

    try {
      final generatedUrl = await _storageService.generateAndUploadAICover(prompt, title: title);

      setState(() {
        _uploadedImageUrl = generatedUrl;
        _simulatedImageName = 'AI Cover: $title (Generated)';
        _imageUrlController.text = generatedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cover AI berhasil dibuat dan diunggah! 🎉', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFF00743B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat Cover AI: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final quote = _showQuote ? _quoteController.text.trim() : '';
    final quoteAuthor = _showQuote ? _quoteAuthorController.text.trim() : '';
    final part1 = _part1Controller.text.trim();
    final part2 = _part2Controller.text.trim();
    final manualUrl = _imageUrlController.text.trim();

    if (title.isEmpty || subtitle.isEmpty || part1.isEmpty || part2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul, subjudul, dan isi cerita harus diisi!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // ── Content Filter: block SARA, NAPZA, violence, adult content ──
    final filterError = ContentFilterService.validate(title, '$subtitle $part1 $part2');
    if (filterError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(filterError, style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    final imagePath = _uploadedImageUrl ?? (manualUrl.isNotEmpty ? manualUrl : 'assets/images/sangkuriang.png');

    // Estimate read time: average 200 words per minute
    final totalWords = part1.split(' ').length + part2.split(' ').length;
    final minutes = (totalWords / 150).ceil();
    final readTime = '$minutes min baca';

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User tidak terautentikasi.');

      if (widget.editStory != null) {
        // Edit existing story
        await _databaseService.updateStory(widget.editStory!.id, {
          'title': title,
          'subtitle': subtitle,
          'imagePath': imagePath,
          'category': _selectedCategory,
          'readTime': readTime,
          'part1': part1,
          'quote': quote,
          'quoteAuthor': quoteAuthor,
          'part2': part2,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cerita "$title" berhasil diperbarui!', style: GoogleFonts.plusJakartaSans()),
              backgroundColor: const Color(0xFF00743B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      } else {
        // Create new story — status 'pending' until admin approves
        final newStory = StoryModel(
          id: '',
          title: title,
          subtitle: subtitle,
          imagePath: imagePath,
          category: _selectedCategory,
          readTime: readTime,
          part1: part1,
          quote: quote,
          quoteAuthor: quoteAuthor,
          part2: part2,
          authorId: user.uid,
          authorName: _authorName,
          timestamp: DateTime.now(),
          status: 'pending', // Must be approved by admin before visible
        );

        await _databaseService.addStory(newStory);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cerita "$title" berhasil dikirim! ✨ Menunggu persetujuan admin.',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: const Color(0xFF00743B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan cerita: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editStory != null;
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF065F46)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Cerita Anda' : 'Tulis Cerita Baru',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF065F46),
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00743B),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bagikan Petualanganmu!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF065F46),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tulis cerita rakyat, fabel, atau legenda versimu sendiri sebagai $_authorName.',
                      style: GoogleFonts.beVietnamPro(fontSize: 14, color: const Color(0xFF64655C)),
                    ),
                    const SizedBox(height: 28),

                    // ── Judul ──
                    _sectionLabel('Judul Cerita'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Contoh: Kisah Si Kancil yang Cerdik',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 20),

                    // ── Subjudul ──
                    _sectionLabel('Subjudul Cerita'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _subtitleController,
                      hint: 'Contoh: Dongeng Si Kecil Penyelamat Hutan',
                      icon: Icons.subtitles_rounded,
                    ),
                    const SizedBox(height: 20),

                    // ── Kategori ──
                    _sectionLabel('Kategori'),
                    const SizedBox(height: 10),
                    Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: EdgeInsets.only(right: cat != _categories.last ? 10 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF00743B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF00743B) : const Color(0xFFE5E7EB),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                cat,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : const Color(0xFF64655C),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Cover Image ──
                    _sectionLabel('Gambar Sampul Cerita'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _imageUrlController,
                      hint: 'Masukkan URL Gambar (opsional)',
                      icon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'ATAU',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _generateAICover,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: _uploadedImageUrl != null && _uploadedImageUrl!.contains('pollinations')
                                    ? const Color(0xFFD1FAE5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _uploadedImageUrl != null && _uploadedImageUrl!.contains('pollinations')
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFD1D5DB),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 32,
                                    color: Color(0xFF059669),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Generate dengan AI',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickAndUpload,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                    ? const Color(0xFFC6F6D5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                      ? const Color(0xFF00743B)
                                      : const Color(0xFFD1D5DB),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                        ? Icons.check_circle_rounded
                                        : Icons.cloud_upload_rounded,
                                    size: 32,
                                    color: _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                        ? const Color(0xFF00743B)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                        ? 'Gambar dipilih ✓'
                                        : 'Unggah Gambar',
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 13,
                                      color: _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF9CA3AF),
                                      fontWeight: _simulatedImageName != null && !_simulatedImageName!.contains('AI')
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_uploadedImageUrl != null && _uploadedImageUrl!.startsWith('http')) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Preview Cover:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                _uploadedImageUrl!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 160,
                                    height: 160,
                                    color: const Color(0xFFECECEC),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00743B),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ── Kutipan Favorit (Opsional) ──
                    _buildQuoteToggle(),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: _showQuote
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _sectionLabel('Kutipan Favorit'),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: _quoteController,
                                  hint: 'Contoh: Jangan pernah melupakan jasa orang tua.',
                                  icon: Icons.format_quote_rounded,
                                ),
                                const SizedBox(height: 16),
                                _sectionLabel('Tokoh Kutipan'),
                                const SizedBox(height: 10),
                                _buildTextField(
                                  controller: _quoteAuthorController,
                                  hint: 'Contoh: Malin Kundang',
                                  icon: Icons.person_outline_rounded,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),

                    // ── Isi Bagian 1 ──
                    _sectionLabel('Isi Cerita - Bagian 1'),
                    const SizedBox(height: 10),
                    _buildTextArea(
                      controller: _part1Controller,
                      hint: 'Tulis paragraf awal cerita Anda di sini...',
                    ),
                    const SizedBox(height: 24),

                    // ── Isi Bagian 2 ──
                    _sectionLabel('Isi Cerita - Bagian 2'),
                    const SizedBox(height: 10),
                    _buildTextArea(
                      controller: _part2Controller,
                      hint: 'Tulis paragraf akhir/lanjutan cerita Anda di sini...',
                    ),
                    const SizedBox(height: 32),

                    // ── Simpan ──
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send_rounded),
                        label: Text(
                          isEditing ? 'Simpan Perubahan' : 'Publikasikan Cerita',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00743B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Toggle kutipan opsional — desain selaras dengan admin form
  Widget _buildQuoteToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showQuote = !_showQuote),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _showQuote ? const Color(0xFFD1FAE5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _showQuote ? const Color(0xFF00743B) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: _showQuote ? const Color(0xFF00743B) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _showQuote ? const Color(0xFF00743B) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: _showQuote
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Kutipan Favorit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _showQuote ? const Color(0xFF065F46) : const Color(0xFF374151),
                  ),
                ),
                Text(
                  'Opsional — kalimat berkesan dari cerita ini',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.format_quote_rounded,
              color: _showQuote ? const Color(0xFF059669) : const Color(0xFFD1D5DB),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF373830)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.beVietnamPro(color: const Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, color: const Color(0xFF059669)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: 6,
        style: GoogleFonts.beVietnamPro(color: const Color(0xFF373830), fontSize: 14, height: 1.6),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.beVietnamPro(color: const Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
