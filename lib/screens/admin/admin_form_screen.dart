import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminFormScreen extends StatefulWidget {
  const AdminFormScreen({super.key});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'LEGENDA';
  String? _imageName;

  final List<String> _categories = ['LEGENDA', 'MITOS', 'FABEL'];

  void _pickImage() {
    // Placeholder: Firebase Storage upload would hook here
    setState(() {
      _imageName = 'gambar_cerita.png';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur upload gambar akan terhubung ke Firebase Storage.',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: const Color(0xFF00743B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cerita "${_titleController.text}" berhasil disimpan!', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: const Color(0xFF00743B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    _titleController.clear();
    _contentController.clear();
    setState(() => _imageName = null);
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
              _sectionLabel('Gambar Cerita'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: _imageName != null
                        ? const Color(0xFFC6F6D5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _imageName != null
                          ? const Color(0xFF00743B)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _imageName != null
                            ? Icons.check_circle_rounded
                            : Icons.cloud_upload_rounded,
                        size: 40,
                        color: _imageName != null
                            ? const Color(0xFF00743B)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _imageName ?? 'Ketuk untuk upload gambar ke Firebase',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          color: _imageName != null
                              ? const Color(0xFF065F46)
                              : const Color(0xFF9CA3AF),
                          fontWeight: _imageName != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (_imageName == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'PNG, JPG hingga 5MB',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 11,
                              color: const Color(0xFFBABAAF),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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
              const SizedBox(height: 12),

              // ── Koordinat (placeholder) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE047), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFFB45309), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Penentuan koordinat lokasi akan hadir segera.',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    'Simpan Cerita',
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
