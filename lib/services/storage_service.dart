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
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    final dio = Dio();
    // Cloudinary menerima base64 data URI langsung
    final base64Data = base64Encode(bytes);
    final dataUri = 'data:$mimeType;base64,$base64Data';
    final formData = FormData.fromMap({
      'file': dataUri,
      'upload_preset': _uploadPreset,
      'folder': 'kisantara_covers',
      'quality': 'auto', // Cloudinary otomatis kompres
      'fetch_format':
          'auto', // Cloudinary auto pilih format terbaik (WebP, dll)
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
      'Cloudinary upload gagal (${response.statusCode}): ${response.data}',
    );
  }

  /// Membuka galeri foto, memilih gambar, lalu mengupload ke Cloudinary.
  /// Returns CDN URL gambar, atau null jika user membatalkan.
  Future<String?> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres di device sebelum upload
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

  /// Generate cover dengan AI menggunakan beberapa fallback:
  /// 1. Hugging Face Inference API (FLUX.1-schnell — gratis & cepat)
  /// 2. Pollinations.ai (tanpa API key)
  /// 3. Placeholder dari picsum.photos (fallback terakhir)
  Future<String> generateAndUploadAICover(String prompt) async {
    // ── Strategi 1: Hugging Face Inference API ──
    try {
      return await _generateViaHuggingFace(prompt);
    } catch (e) {
      debugPrint('[AI Cover] HuggingFace gagal: $e — mencoba Pollinations...');
    }

    // ── Strategi 2: Pollinations.ai (tanpa API key) ──
    try {
      return await _generateViaPollinations(prompt);
    } catch (e) {
      debugPrint(
        '[AI Cover] Pollinations gagal: $e — menggunakan placeholder...',
      );
    }

    // ── Strategi 3: Placeholder image dari picsum.photos ──
    return await _generatePlaceholder();
  }

  /// Strategi 1: Hugging Face standard Inference API
  Future<String> _generateViaHuggingFace(String prompt) async {
    final dio = Dio();

    // Gunakan FLUX.1-schnell (gratis, cepat ~2-4 detik)
    const modelUrl =
        'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-schnell';

    final response = await dio.post(
      modelUrl,
      data: {'inputs': prompt},
      options: Options(
        headers: {
          'Authorization': 'Bearer $hfToken',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.bytes,
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('HF API code ${response.statusCode}');
    }

    // Cek apakah response berisi JSON error (model loading)
    final data = response.data as List<int>;
    if (data.length < 1000) {
      // Kemungkinan JSON error, bukan image bytes
      try {
        final decoded = utf8.decode(data);
        final json = jsonDecode(decoded);
        if (json is Map && json.containsKey('error')) {
          throw Exception(json['error']);
        }
      } catch (e) {
        if (e is Exception) rethrow;
      }
    }

    final bytes = Uint8List.fromList(data);
    final fileName = 'ai_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadBytes(bytes, fileName, 'image/jpeg');
  }

  /// Strategi 2: Pollinations.ai — tanpa API key, cukup GET URL
  Future<String> _generateViaPollinations(String prompt) async {
    final dio = Dio();
    final encodedPrompt = Uri.encodeComponent(prompt);
    final url =
        'https://image.pollinations.ai/prompt/$encodedPrompt?width=512&height=512&nologo=true';

    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Pollinations code ${response.statusCode}');
    }

    final bytes = Uint8List.fromList(response.data);
    if (bytes.length < 1000) {
      throw Exception('Pollinations mengembalikan data terlalu kecil');
    }

    final fileName = 'ai_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadBytes(bytes, fileName, 'image/jpeg');
  }

  /// Strategi 3: Placeholder — selalu berhasil
  Future<String> _generatePlaceholder() async {
    final dio = Dio();
    final seed = DateTime.now().millisecondsSinceEpoch;
    final url = 'https://picsum.photos/seed/$seed/512/512';

    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Placeholder gagal (${response.statusCode})');
    }

    final bytes = Uint8List.fromList(response.data);
    final fileName = 'placeholder_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadBytes(bytes, fileName, 'image/jpeg');
  }
}
