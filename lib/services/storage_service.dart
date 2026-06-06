import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// StorageService menggunakan Cloudinary (bukan Firebase Storage)
/// - Gratis: 25 GB storage + 25 GB bandwidth/bulan
/// - Cepat: CDN global, otomatis optimasi gambar
/// - Mudah: REST API biasa, tidak perlu SDK
class StorageService {
  static const String _cloudName = 'dau1ypcyi';
  static const String _uploadPreset = 'kisantara_unsigned';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload raw byte data ke Cloudinary. Returns secure CDN URL.
  Future<String> uploadBytes(
      Uint8List bytes, String fileName, String mimeType) async {
    final dio = Dio();
    // Cloudinary menerima base64 data URI langsung
    final base64Data = base64Encode(bytes);
    final dataUri = 'data:$mimeType;base64,$base64Data';
    final formData = FormData.fromMap({
      'file': dataUri,
      'upload_preset': _uploadPreset,
      'folder': 'kisantara_covers',
      'quality': 'auto',      // Cloudinary otomatis kompres
      'fetch_format': 'auto', // Cloudinary auto pilih format terbaik (WebP, dll)
    });
    final response = await dio.post(
      _uploadUrl,
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    if (response.statusCode == 200) {
      final secureUrl = response.data['secure_url'] as String;
      return secureUrl;
    }
    throw Exception(
        'Cloudinary upload gagal (${response.statusCode}): ${response.data}');
  }

  /// Membuka galeri foto, memilih gambar, lalu mengupload ke Cloudinary.
  /// Returns CDN URL gambar, atau null jika user membatalkan.
  Future<String?> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,  // Kompres di device sebelum upload
        maxWidth: 900,
        maxHeight: 900,
      );
      if (image == null) return null; // User batal pilih

      final bytes = await image.readAsBytes();
      final name = image.name.toLowerCase();
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.$ext';
      return await uploadBytes(bytes, fileName, mimeType);
    } catch (e) {
      rethrow;
    }
  }
}
