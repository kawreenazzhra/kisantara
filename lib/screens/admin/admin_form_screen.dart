import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/content_filter_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../models/story_model.dart';

class AdminFormScreen extends StatefulWidget {
  const AdminFormScreen({super.key});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'LEGENDA';
  String? _imageName;
  String? _uploadedImageUrl;
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  final List<String> _categories = ['LEGENDA', 'MITOS', 'FABEL'];

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

  void _generateAICover() {
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

    final prompt = "indonesian folklore story about $title, category $_selectedCategory, digital art style, beautiful detailed fantasy illustration, kids friendly, colorful";
    final seed = DateTime.now().millisecondsSinceEpoch;
    final generatedUrl = "https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}?width=800&height=800&nologo=true&seed=$seed";

    setState(() {
      _uploadedImageUrl = generatedUrl;
      _imageName = 'AI Cover: $title (Generated)';
      _imageUrlController.text = generatedUrl;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cover AI sedang dibuat! Mohon tunggu pratinjau muncul.', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: const Color(0xFF00743B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul dan isi cerita tidak boleh kosong!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    // Content filter for admin submissions too
    final filterError = ContentFilterService.validate(title, content);
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

    final imagePath = _uploadedImageUrl ?? 'assets/images/sangkuriang.png';
    final totalWords = content.split(' ').length;
    final minutes = (totalWords / 150).ceil();
    final readTime = '$minutes min baca';

    // Split content into part1 and part2
    final halfLength = (content.length / 2).ceil();
    final part1 = content.substring(0, halfLength);
    final part2 = content.substring(halfLength);

    setState(() => _isLoading = true);

    try {
      final newStory = StoryModel(
        id: '',
        title: title,
        subtitle: 'Kisantara', // Admin stories are credited to Kisantara
        imagePath: imagePath,
        category: _selectedCategory,
        readTime: readTime,
        part1: part1,
        quote: '',
        quoteAuthor: '',
        part2: part2,
        authorId: 'admin',
        authorName: 'Kisantara',
        timestamp: DateTime.now(),
        status: 'approved', // Admin stories are immediately approved
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
        _contentController.clear();
        _imageUrlController.clear();
        setState(() {
          _imageName = null;
          _uploadedImageUrl = null;
        });
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
    return Scaffold(
      backgroundColor: const Color(0xFFFEFDF1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Cerita',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF065F46),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tambahkan dongeng dan cerita rakyat baru ke koleksi Kisantara.',
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

              // ── Isi Cerita ──
              _sectionLabel('Isi Dongeng'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF064E3B).withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: 10,
                  style: GoogleFonts.beVietnamPro(
                    color: const Color(0xFF373830),
                    fontSize: 14,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis isi dongeng di sini...',
                    hintStyle: GoogleFonts.beVietnamPro(color: const Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
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
                    _isLoading ? 'Menyimpan...' : 'Simpan Cerita',
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
            color: const Color(0xFF064E3B).withOpacity(0.02),
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
}
