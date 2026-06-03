/// ContentFilterService
/// Filters user-submitted text content for inappropriate words/phrases
/// related to SARA (ethnicity/race/religion/inter-group), NAPZA (drugs),
/// violence, pornography, and other content unsuitable for children.
class ContentFilterService {
  static const List<String> _blockedWords = [
    // ── SARA ──
    'kafir', 'anjing', 'babi', 'iblis', 'setan', 'laknat', 'hina', 'rendah',
    'bangsa rendah', 'ras rendah', 'pribumi', 'aseng', 'cina babi', 'negro',
    'nigger', 'racist', 'rasis', 'diskriminasi agama', 'penista',

    // ── NAPZA (Narkotika, Psikotropika, Zat Adiktif) ──
    'narkoba', 'narkotika', 'sabu', 'shabu', 'ganja', 'kokain', 'heroin',
    'ekstasi', 'ecstasy', 'morphine', 'morfin', 'fentanyl', 'methamphetamine',
    'marijuana', 'cannabis', 'opium', 'overdosis', 'nyabu', 'mabuk narkoba',
    'pakai narkoba', 'jual narkoba', 'beli narkoba', 'bandar narkoba',

    // ── Kekerasan ──
    'membunuh', 'bunuh diri', 'bunuh', 'membantai', 'menyiksa', 'disiksa',
    'bacok', 'tikam', 'bakar hidup', 'mutilasi', 'pemerkosaan', 'rudapaksa',
    'menganiaya', 'teror', 'bom', 'mengebom', 'meledakkan',

    // ── Konten Dewasa / Pornografi ──
    'pornografi', 'porno', 'bokep', 'ngentot', 'memek', 'kontol', 'penis',
    'vagina', 'seks', 'sex', 'sexs', 'hubungan intim', 'bersetubuh',
    'telanjang', 'bugil', 'cabul',

    // ── Kata Kasar Umum ──
    'bajingan', 'keparat', 'brengsek', 'tai', 'kampret', 'asu', 'jancok',
    'jancuk', 'goblok', 'idiot', 'tolol', 'bodoh', 'bego', 'gila',
    'fuck', 'shit', 'damn', 'bastard', 'asshole', 'bitch', 'dick', 'pussy',
    'cunt',
  ];

  /// Returns true if text is SAFE to publish (no blocked words found).
  static bool isSafe(String text) {
    return findViolations(text).isEmpty;
  }

  /// Returns list of blocked words/phrases found in text.
  static List<String> findViolations(String text) {
    final lower = text.toLowerCase();
    return _blockedWords.where((word) => lower.contains(word)).toList();
  }

  /// Returns a user-friendly error message if violations found, or null if safe.
  static String? validate(String title, String content) {
    final titleViolations = findViolations(title);
    if (titleViolations.isNotEmpty) {
      return 'Judul mengandung konten yang tidak sesuai (${titleViolations.first}). Kisantara adalah platform ramah anak 🌿';
    }

    final contentViolations = findViolations(content);
    if (contentViolations.isNotEmpty) {
      return 'Isi cerita mengandung konten yang tidak sesuai (${contentViolations.first}). Pastikan cerita Anda ramah anak 🌿';
    }

    return null; // all good
  }
}
