import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  /// 1. Pollinations GPT Image (paling akurat mengikuti prompt)
  /// 2. Pollinations Flux Schnell (cepat, fallback)
  /// 3. DeepAI Text-to-Image API (backup)
  /// 4. Placeholder dari picsum.photos (fallback terakhir)
  ///
  /// [prompt] — prompt bahasa Inggris dari buildSmartPrompt
  /// [title] — judul asli untuk generate seed (konsistensi gambar)
  Future<String> generateAndUploadAICover(String prompt, {String title = ''}) async {
    // Buat seed dari judul agar judul yang sama → gambar yang konsisten
    final seed = _generateSeedFromTitle(title);

    // ── Strategi 1: GPT Image via Pollinations (paling akurat) ──
    try {
      return await _generateViaPollinations(prompt, model: 'gptimage', seed: seed);
    } catch (e) {
      debugPrint('[AI Cover] GPT Image gagal: $e — mencoba Flux...');
    }

    // ── Strategi 2: Flux Schnell via Pollinations (cepat) ──
    try {
      return await _generateViaPollinations(prompt, model: 'flux', seed: seed);
    } catch (e) {
      debugPrint('[AI Cover] Flux gagal: $e — mencoba DeepAI...');
    }

    // ── Strategi 3: DeepAI Text-to-Image API ──
    try {
      return await _generateViaDeepAI(prompt);
    } catch (e) {
      debugPrint(
        '[AI Cover] DeepAI gagal: $e — menggunakan placeholder...',
      );
    }

    // ── Strategi 4: Placeholder image dari picsum.photos ──
    return await _generatePlaceholder();
  }

  /// Generate seed number dari judul cerita.
  /// Judul yang sama akan selalu menghasilkan seed yang sama → gambar konsisten.
  int _generateSeedFromTitle(String title) {
    if (title.isEmpty) return DateTime.now().millisecondsSinceEpoch % 100000;
    int hash = 0;
    for (int i = 0; i < title.length; i++) {
      hash = (hash * 31 + title.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash % 100000;
  }

  /// Kamus kata Indonesia → English untuk konteks cerita rakyat
  static const Map<String, String> _idToEnKeywords = {
    // Hewan
    'kancil': 'clever mouse deer',
    'buaya': 'crocodile',
    'harimau': 'tiger',
    'kura-kura': 'turtle',
    'kura kura': 'turtle',
    'burung': 'bird',
    'garuda': 'giant eagle garuda',
    'naga': 'dragon',
    'ikan': 'fish',
    'monyet': 'monkey',
    'gajah': 'elephant',
    'singa': 'lion',
    'kelinci': 'rabbit',
    'ayam': 'chicken rooster',
    'elang': 'eagle',
    'ular': 'snake serpent',
    'rusa': 'deer',
    'angsa': 'swan',
    'kupu-kupu': 'butterfly',
    'kupu kupu': 'butterfly',
    'lebah': 'bee',
    'semut': 'ant',
    // Tempat & Alam
    'danau': 'lake',
    'gunung': 'mountain',
    'hutan': 'forest jungle',
    'laut': 'sea ocean',
    'sungai': 'river',
    'desa': 'village',
    'kerajaan': 'kingdom palace',
    'istana': 'royal palace',
    'pantai': 'beach coast',
    'sawah': 'rice field paddy',
    'gua': 'cave',
    'pulau': 'island',
    'taman': 'garden',
    'candi': 'ancient temple',
    // Karakter
    'putri': 'princess',
    'pangeran': 'prince',
    'raja': 'king',
    'ratu': 'queen',
    'ksatria': 'knight warrior',
    'peri': 'fairy',
    'raksasa': 'giant monster',
    'jin': 'genie spirit',
    'nenek': 'grandmother elderly woman',
    'kakek': 'grandfather elderly man',
    'petani': 'farmer',
    'nelayan': 'fisherman',
    'pemburu': 'hunter',
    'pedagang': 'merchant trader',
    'penyihir': 'sorcerer witch',
    'dewi': 'goddess',
    'dewa': 'god deity',
    'bidadari': 'celestial maiden angel',
    'anak': 'child kid',
    // Elemen cerita
    'emas': 'golden gold',
    'perak': 'silver',
    'ajaib': 'magical enchanted',
    'sakti': 'powerful mystical',
    'kutukan': 'curse cursed',
    'sayap': 'wings winged',
    'selendang': 'magical scarf shawl',
    'tongkat': 'staff wand',
    'permata': 'gemstone jewel',
    'mahkota': 'crown',
    'pedang': 'sword',
    'perisai': 'shield',
    'batu': 'stone rock',
    'api': 'fire flame',
    'air': 'water',
    'cahaya': 'light radiant',
    'gelap': 'dark darkness',
    'hujan': 'rain',
    'petir': 'thunder lightning',
    'pelangi': 'rainbow',
    'bulan': 'moon',
    'matahari': 'sun',
    'bintang': 'star',
    // Konsep
    'cinta': 'love romance',
    'perang': 'war battle',
    'persahabatan': 'friendship',
    'keberanian': 'bravery courage',
    'pengorbanan': 'sacrifice',
    'kebaikan': 'kindness goodness',
    'legenda': 'legend legendary',
    'misteri': 'mystery mysterious',
    'petualangan': 'adventure',
    'perjalanan': 'journey quest',
    'terbang': 'flying flight',
    'menari': 'dancing dance',
    'bernyanyi': 'singing',
    // Lokasi Indonesia
    'jawa': 'Javanese Java',
    'sumatra': 'Sumatran Sumatra',
    'sumatera': 'Sumatran Sumatra',
    'kalimantan': 'Borneo Kalimantan',
    'sulawesi': 'Sulawesi Celebes',
    'bali': 'Balinese Bali',
    'papua': 'Papuan Papua',
    'minang': 'Minangkabau West Sumatra',
    'sunda': 'Sundanese West Java',
    'bugis': 'Bugis South Sulawesi',
    'dayak': 'Dayak Borneo tribe',
    'batak': 'Batak North Sumatra',
    'toraja': 'Toraja South Sulawesi',
  };

  /// Mapping kategori Indonesia → English dengan deskripsi visual
  static const Map<String, String> _categoryMap = {
    'LEGENDA': 'legendary origin story',
    'MITOS': 'mythological tale',
    'FABEL': 'animal fable',
    'DONGENG': 'fairy tale',
    'SAGE': 'heroic saga',
  };

  /// Mapping kata kunci → scene/background yang sesuai
  static const Map<String, String> _sceneKeywords = {
    // Lokasi air
    'danau': 'a serene mystical lake surrounded by tropical mountains',
    'laut': 'a dramatic ocean coast with crashing waves',
    'sungai': 'a winding river through a lush tropical valley',
    'pantai': 'a beautiful tropical beach at sunset',
    'ikan': 'an underwater coral reef scene',
    'nelayan': 'a fishing village by the sea at dawn',
    // Lokasi darat
    'gunung': 'a majestic volcanic mountain landscape',
    'hutan': 'a dense tropical rainforest with sunbeams',
    'desa': 'a traditional Indonesian village with wooden houses',
    'sawah': 'terraced rice paddy fields bathed in golden light',
    'gua': 'a mysterious ancient cave with glowing crystals',
    'pulau': 'a lush tropical island paradise',
    'taman': 'an enchanted magical garden full of exotic flowers',
    'candi': 'an ancient stone temple like Borobudur at dawn',
    // Lokasi kerajaan
    'kerajaan': 'a grand Southeast Asian palace with golden spires',
    'istana': 'an ornate royal palace interior with batik tapestry',
    'raja': 'a grand throne room in a Javanese palace',
    'ratu': 'an elegant royal court with golden ornaments',
    'putri': 'a beautiful palace balcony overlooking a kingdom',
    'pangeran': 'a royal courtyard with tropical gardens',
    // Alam & cuaca
    'bulan': 'a moonlit night sky over ancient ruins',
    'matahari': 'a glorious sunrise over an Indonesian landscape',
    'bintang': 'a starry night sky over a tropical island',
    'pelangi': 'a rainbow arching over a green valley',
    'hujan': 'a mystical rainy tropical forest',
    'petir': 'a dramatic stormy sky with lightning',
    // Makhluk
    'naga': 'a volcanic mountain lair with treasure',
    'bidadari': 'heavenly clouds and a celestial palace',
    'peri': 'an enchanted moonlit forest glade',
    'raksasa': 'a dark ominous mountain fortress',
    'jin': 'mystical smoke-filled ancient ruins',
  };

  /// Mapping preset untuk cerita rakyat terkenal agar menghasilkan gambar yang sangat akurat.
  static const Map<String, String> _folklorePresets = {
    'kancil': 'storybook illustration of a clever little mouse deer standing on the backs of crocodiles lined up across a tropical jungle river',
    'buaya': 'storybook illustration of a clever little mouse deer standing on the backs of crocodiles lined up across a tropical jungle river',
    'toba': 'storybook illustration of a massive volcanic lake with a green island in the middle, traditional Batak houses, sunny sky',
    'samosir': 'storybook illustration of a massive volcanic lake with a green island in the middle, traditional Batak houses, sunny sky',
    'sangkuriang': 'storybook illustration of a powerful mythical man kicking a large wooden ship upside down, turning it into a mountain',
    'tangkuban': 'storybook illustration of a powerful mythical man kicking a large wooden ship upside down, turning it into a mountain',
    'malin': 'storybook illustration of a young man kneeling and turning into a stone statue on a stormy beach next to a wrecked wooden ship',
    'kundang': 'storybook illustration of a young man kneeling and turning into a stone statue on a stormy beach next to a wrecked wooden ship',
    'jonggrang': 'storybook illustration of a beautiful princess transforming into a stone statue inside a majestic ancient stone temple, mystical golden light',
    'prambanan': 'storybook illustration of a beautiful princess transforming into a stone statue inside a majestic ancient stone temple, mystical golden light',
    'bawang': 'storybook illustration of a kind traditional Indonesian girl holding a magical glowing pumpkin filled with gold and jewels',
    'keong': 'storybook illustration of a beautiful princess emerging from a large glowing golden snail shell, tropical beach background',
    'timun': 'storybook illustration of a young Indonesian girl running away in a tropical field from a giant green monster',
    'sura': 'storybook illustration of a white shark and a green crocodile fighting in splashing blue water, dynamic action',
    'lutung': 'storybook illustration of a black monkey prince next to a beautiful princess in a Javanese mystical forest',
    'tarub': 'storybook illustration of a Javanese man hiding in the jungle, watching beautiful celestial maidens bathing in a waterfall lake',
  };

  /// Membangun prompt bahasa Inggris yang jelas dan deskriptif.
  String buildSmartPrompt(String title, String category) {
    final titleLower = title.toLowerCase();

    // 1. Cek apakah ada preset cerita rakyat terkenal yang cocok
    String? presetDescription;
    for (final entry in _folklorePresets.entries) {
      if (titleLower.contains(entry.key)) {
        presetDescription = entry.value;
        break;
      }
    }

    if (presetDescription != null) {
      final prompt = '$presetDescription. '
          'Style: warm colorful Southeast Asian folklore illustration, '
          'hand-painted watercolor and digital art hybrid, '
          'ornate batik-inspired decorative border, '
          'children\'s book cover quality.';
      debugPrint('[AI Cover] Preset Prompt: $prompt');
      return prompt;
    }

    // 2. Jika tidak ada preset, gunakan model translasi kata kunci fallback
    final categoryEn = _categoryMap[category.toUpperCase()] ?? 'folklore';
    final translatedWords = <String>[];

    String remaining = titleLower;
    final sortedKeys = _idToEnKeywords.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final key in sortedKeys) {
      if (remaining.contains(key)) {
        translatedWords.add(_idToEnKeywords[key]!);
        remaining = remaining.replaceAll(key, ' ');
      }
    }

    // Tentukan scene/background
    String scene = '';
    for (final key in _sceneKeywords.keys) {
      if (titleLower.contains(key)) {
        scene = _sceneKeywords[key]!;
        break;
      }
    }

    if (scene.isEmpty) {
      switch (category.toUpperCase()) {
        case 'FABEL':
          scene = 'a tropical jungle with exotic plants and animals';
          break;
        case 'LEGENDA':
          scene = 'ancient Indonesian temple ruins at golden hour';
          break;
        case 'MITOS':
          scene = 'a mystical foggy forest with ethereal glowing light';
          break;
        case 'DONGENG':
          scene = 'a magical enchanted forest with glowing fireflies';
          break;
        case 'SAGE':
          scene = 'an epic battlefield with dramatic cloudy sky';
          break;
        default:
          scene = 'a lush tropical Indonesian landscape';
      }
    }

    final subject = translatedWords.isNotEmpty
        ? translatedWords.join(' and ')
        : 'mythical character';

    // PENTING: Kami TIDAK menyertakan literal title "called $title" di prompt
    // agar generator AI tidak kebingungan dengan teks bahasa Indonesia.
    final prompt =
        'A beautiful storybook illustration for an Indonesian $categoryEn. '
        'The scene shows $subject in $scene. '
        'Style: warm colorful Southeast Asian folklore illustration, '
        'hand-painted watercolor and digital art hybrid, '
        'ornate batik-inspired decorative border, '
        'children\'s book cover quality.';

    debugPrint('[AI Cover] Smart Prompt: $prompt');
    return prompt;
  }

  /// Strategi 1 & 2: Pollinations.ai — endpoint baru gen.pollinations.ai
  /// Model gratis: gptimage (GPT Image, paling akurat), flux (Flux Schnell, cepat)
  Future<String> _generateViaPollinations(String prompt, {required String model, int? seed}) async {
    final dio = Dio();
    final encodedPrompt = Uri.encodeComponent(prompt);
    final seedParam = seed ?? DateTime.now().millisecondsSinceEpoch % 100000;

    // Endpoint baru Pollinations: gen.pollinations.ai/image/{prompt}
    // - model: gptimage (GPT Image 1 Mini) atau flux (Flux Schnell)
    // - seed: untuk konsistensi gambar
    // - nologo: tanpa watermark
    final url =
        'https://gen.pollinations.ai/image/$encodedPrompt'
        '?width=512&height=512'
        '&seed=$seedParam'
        '&model=$model'
        '&nologo=true';

    debugPrint('[AI Cover] Pollinations model=$model seed=$seedParam');

    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 180),
        followRedirects: true,
        maxRedirects: 10,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Pollinations $model code ${response.statusCode}');
    }

    final bytes = Uint8List.fromList(response.data);
    if (bytes.length < 1000) {
      throw Exception('Pollinations $model mengembalikan data terlalu kecil (${bytes.length} bytes)');
    }

    // Verifikasi bahwa response adalah gambar (bukan HTML error page)
    // JPEG mulai dengan 0xFF 0xD8, PNG mulai dengan 0x89 0x50
    if (bytes.length > 4) {
      final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
      final isPng = bytes[0] == 0x89 && bytes[1] == 0x50;
      final isWebp = bytes.length > 12 &&
          bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50;
      if (!isJpeg && !isPng && !isWebp) {
        throw Exception('Pollinations $model mengembalikan data bukan gambar');
      }
    }

    final ext = (bytes[0] == 0x89) ? 'png' : 'jpg';
    final mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
    final fileName = 'ai_cover_${DateTime.now().millisecondsSinceEpoch}.$ext';
    return await uploadBytes(bytes, fileName, mimeType);
  }

  /// Strategi 3: DeepAI Text-to-Image API
  /// Gratis dengan demo API key, stabil dan cepat.
  Future<String> _generateViaDeepAI(String prompt) async {
    final dio = Dio();

    // DeepAI free demo API key
    const apiKey = '78c56ace-9a3d-4f35-bce1-543c51de609a';
    const apiUrl = 'https://api.deepai.org/api/text2img';

    final response = await dio.post(
      apiUrl,
      data: FormData.fromMap({'text': prompt}),
      options: Options(
        headers: {
          'Api-Key': apiKey,
        },
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('DeepAI API code ${response.statusCode}');
    }

    // DeepAI mengembalikan JSON: { "output_url": "https://..." }
    final responseData = response.data;
    if (responseData is! Map || !responseData.containsKey('output_url')) {
      final errorMsg = responseData is Map
          ? (responseData['err'] ?? responseData['error'] ?? 'Unknown error')
          : 'Unexpected response format';
      throw Exception('DeepAI error: $errorMsg');
    }

    final imageUrl = responseData['output_url'] as String;

    // Download gambar dari DeepAI output URL lalu upload ke Cloudinary
    final imageResponse = await dio.get(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    if (imageResponse.statusCode != 200) {
      throw Exception('Gagal download gambar DeepAI (${imageResponse.statusCode})');
    }

    final bytes = Uint8List.fromList(imageResponse.data);
    if (bytes.length < 1000) {
      throw Exception('DeepAI mengembalikan data terlalu kecil');
    }

    final fileName = 'ai_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadBytes(bytes, fileName, 'image/jpeg');
  }

  /// Strategi 4: Placeholder — selalu berhasil
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
