import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/content_filter_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/story_model.dart';

class AdminFormScreen extends StatefulWidget {
  final StoryModel? editStory;

  const AdminFormScreen({super.key, this.editStory});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _part1Controller = TextEditingController();
  final _part2Controller = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _quoteController = TextEditingController();
  final _quoteAuthorController = TextEditingController();

  String _selectedCategory = 'LEGENDA';
  String? _imageName;
  String? _uploadedImageUrl;
  bool _isLoading = false;
  bool _showQuote = false; // Kutipan opsional

  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  final List<String> _categories = ['LEGENDA', 'MITOS', 'FABEL'];

  @override
  void initState() {
    super.initState();
    if (widget.editStory != null) {
      final story = widget.editStory!;
      _titleController.text = story.title;
      _subtitleController.text = story.subtitle;
      _part1Controller.text = story.part1;
      _part2Controller.text = story.part2;
      _quoteController.text = story.quote;
      _quoteAuthorController.text = story.quoteAuthor;
      _selectedCategory = story.category.toUpperCase();
      
      if (story.quote.isNotEmpty) _showQuote = true;

      if (story.imagePath.startsWith('http')) {
        _imageUrlController.text = story.imagePath;
        _uploadedImageUrl = story.imagePath;
      } else {
        _imageName = story.imagePath.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _part1Controller.dispose();
    _part2Controller.dispose();
    _imageUrlController.dispose();
    _quoteController.dispose();
    _quoteAuthorController.dispose();
    super.dispose();
  }

  void _pickAndUpload() async {
    setState(() => _isLoading = true);
    try {
      final downloadUrl = await _storageService.pickAndUploadImage();
      if (downloadUrl == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _imageName = 'Gambar diunggah ✓';
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
      if (mounted) setState(() => _isLoading = false);
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
        _imageName = 'AI Cover: $title (Generated)';
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
    final part1 = _part1Controller.text.trim();
    final part2 = _part2Controller.text.trim();
    final quote = _showQuote ? _quoteController.text.trim() : '';
    final quoteAuthor = _showQuote ? _quoteAuthorController.text.trim() : '';

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

    // Content filter
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

    final imagePath = _uploadedImageUrl ?? _imageUrlController.text.trim();
    final finalImagePath = imagePath.isNotEmpty ? imagePath : 'assets/images/sangkuriang.png';
    final totalWords = part1.split(' ').length + part2.split(' ').length;
    final minutes = (totalWords / 150).ceil();
    final readTime = '$minutes min baca';

    setState(() => _isLoading = true);

    try {
      if (widget.editStory != null) {
        // Update existing story
        await _databaseService.updateStory(widget.editStory!.id, {
          'title': title,
          'subtitle': subtitle,
          'imagePath': finalImagePath,
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
          Navigator.of(context).pop(); // Go back after editing
        }
      } else {
        // Add new story
        final newStory = StoryModel(
          id: '',
          title: title,
          subtitle: subtitle,
          imagePath: finalImagePath,
          category: _selectedCategory,
          readTime: readTime,
          part1: part1,
          quote: quote,
          quoteAuthor: quoteAuthor,
          part2: part2,
          authorId: 'admin',
          authorName: 'Kisantara',
          timestamp: DateTime.now(),
          status: 'approved',
        );

        await _databaseService.addStory(newStory);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cerita "$title" berhasil dipublikasikan!', style: GoogleFonts.plusJakartaSans()),
              backgroundColor: const Color(0xFF00743B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
          _titleController.clear();
          _subtitleController.clear();
          _part1Controller.clear();
          _part2Controller.clear();
          _imageUrlController.clear();
          _quoteController.clear();
          _quoteAuthorController.clear();
          setState(() {
            _imageName = null;
            _uploadedImageUrl = null;
            _showQuote = false;
          });
        }
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
      appBar: isEditing ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF065F46)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ) : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Cerita' : 'Tambah Cerita',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEditing ? 'Perbarui informasi dan isi cerita ini.' : 'Tambahkan dongeng dan cerita rakyat baru ke koleksi Kisantara.',
                style: GoogleFonts.beVietnamPro(fontSize: 14, color: const Color(0xFF64655C)),
              ),
              const SizedBox(height: 32),

              // ── Judul ──
              _sectionLabel('Judul Cerita'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _titleController,
                hint: 'Contoh: Malin Kundang',
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 20),

              // ── Subjudul ──
              _sectionLabel('Subjudul Cerita'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _subtitleController,
                hint: 'Contoh: Kisah Anak Durhaka',
                icon: Icons.subtitles_rounded,
              ),
              const SizedBox(height: 24),

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

              // ── Upload Gambar ──
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
                  // Generate AI Cover
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
                  // Real file upload
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _pickAndUpload,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _imageName != null && !(_imageName?.contains('AI') ?? false)
                              ? const Color(0xFFC6F6D5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _imageName != null && !(_imageName?.contains('AI') ?? false)
                                ? const Color(0xFF00743B)
                                : const Color(0xFFD1D5DB),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _imageName != null && !(_imageName?.contains('AI') ?? false)
                                  ? Icons.check_circle_rounded
                                  : Icons.cloud_upload_rounded,
                              size: 32,
                              color: _imageName != null && !(_imageName?.contains('AI') ?? false)
                                  ? const Color(0xFF00743B)
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _imageName != null && !(_imageName?.contains('AI') ?? false)
                                  ? 'Gambar dipilih ✓'
                                  : 'Unggah Gambar',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 13,
                                color: _imageName != null && !(_imageName?.contains('AI') ?? false)
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF9CA3AF),
                                fontWeight: _imageName != null && !(_imageName?.contains('AI') ?? false)
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
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '* Mohon maaf jika gambar yang dihasilkan oleh AI kami tidak sesuai dengan judul Anda. Silakan unggah gambar yang dibuat sendiri agar sesuai dengan cerita yang dibuat.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB45309),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
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
                          errorBuilder: (context, error, stack) => Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECECEC),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported_rounded, color: Color(0xFF9CA3AF), size: 32),
                                SizedBox(height: 6),
                                Text('Gambar AI\nsedang dibuat...', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ── Isi Cerita 1 ──
              _sectionLabel('Isi Cerita - Bagian 1'),
              const SizedBox(height: 10),
              _buildTextArea(
                controller: _part1Controller,
                hint: 'Tulis paragraf awal cerita Anda di sini...',
              ),
              const SizedBox(height: 24),

              // ── Isi Cerita 2 ──
              _sectionLabel('Isi Cerita - Bagian 2'),
              const SizedBox(height: 10),
              _buildTextArea(
                controller: _part2Controller,
                hint: 'Tulis paragraf akhir/lanjutan cerita Anda di sini...',
              ),
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
              const SizedBox(height: 36),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isLoading ? 'Menyimpan...' : (isEditing ? 'Simpan Perubahan' : 'Simpan Cerita'),
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

  /// Toggle untuk kutipan opsional — desain sama persis dengan write_story_screen
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
