import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translator/translator.dart';

class TranslationScript {
  static final _db = FirebaseFirestore.instance;
  static final _translator = GoogleTranslator();

  /// Step 1: Ensure all existing stories have a 'language' field.
  /// Legacy documents without the field will get 'Bahasa Indonesia' added.
  static Future<void> _migrateLegacyStories(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    for (var doc in docs) {
      final data = doc.data();
      if (!data.containsKey('language') || (data['language'] as String?)?.isEmpty == true) {
        await _db.collection('stories').doc(doc.id).update({
          'language': 'Bahasa Indonesia',
        });
        print('[Migration] Added language field to: "${data['title']}"');
      }
    }
  }

  /// Main translation function.
  static Future<void> runAutomatedTranslation() async {
    try {
      print('=== Starting automated translation script ===');

      // Fetch ALL stories
      final snapshot = await _db.collection('stories').get();

      if (snapshot.docs.isEmpty) {
        print('No stories found in database.');
        return;
      }

      print('Found ${snapshot.docs.length} total stories in database.');

      // Step 1: Migrate legacy stories (add language field)
      await _migrateLegacyStories(snapshot.docs);

      // Step 2: Identify original (Indonesian) stories to translate
      final originalStories = snapshot.docs.where((doc) {
        final data = doc.data();
        final lang = data['language'] ?? 'Bahasa Indonesia';
        return lang == 'Bahasa Indonesia';
      }).toList();

      print('Found ${originalStories.length} Indonesian stories to translate.');

      if (originalStories.isEmpty) {
        print('No Indonesian stories to translate.');
        return;
      }

      // Step 3: Find already-translated stories to avoid duplicates
      final existingTranslations = snapshot.docs.where((doc) {
        final data = doc.data();
        return data.containsKey('originalId') && data['originalId'] != null;
      }).toList();

      // Build a set of "originalId_language" for quick lookup
      final translatedSet = <String>{};
      for (var doc in existingTranslations) {
        final data = doc.data();
        final origId = data['originalId'] as String? ?? '';
        final lang = data['language'] as String? ?? '';
        if (origId.isNotEmpty && lang.isNotEmpty) {
          translatedSet.add('${origId}_$lang');
        }
      }

      print('Found ${translatedSet.length} existing translations. Skipping duplicates.');

      final targetLanguages = [
        {'name': 'English', 'code': 'en'},
        {'name': 'Jawa', 'code': 'jv'},
        {'name': 'Sunda', 'code': 'su'},
      ];

      int translatedCount = 0;
      int skippedCount = 0;

      for (var doc in originalStories) {
        final data = doc.data();
        final originalTitle = data['title'] ?? 'Untitled';

        for (var lang in targetLanguages) {
          final langName = lang['name']!;
          final langCode = lang['code']!;

          // Check duplicate using our set
          final key = '${doc.id}_$langName';
          if (translatedSet.contains(key)) {
            skippedCount++;
            continue;
          }

          print('Translating "$originalTitle" to $langName...');

          try {
            // Translate text fields safely
            String title = data['title'] ?? '';
            String subtitle = data['subtitle'] ?? '';
            String part1 = data['part1'] ?? '';
            String part2 = data['part2'] ?? '';
            String quote = data['quote'] ?? '';

            if (title.isNotEmpty) {
              title = (await _translator.translate(title, to: langCode)).text;
            }
            if (subtitle.isNotEmpty) {
              subtitle = (await _translator.translate(subtitle, to: langCode)).text;
            }
            if (part1.isNotEmpty) {
              part1 = (await _translator.translate(part1, to: langCode)).text;
            }
            if (part2.isNotEmpty) {
              part2 = (await _translator.translate(part2, to: langCode)).text;
            }
            if (quote.isNotEmpty) {
              quote = (await _translator.translate(quote, to: langCode)).text;
            }

            // DO NOT translate category - keep original so filtering still works
            final newData = <String, dynamic>{
              ...data,
              'title': title,
              'subtitle': subtitle,
              'part1': part1,
              'part2': part2,
              'quote': quote,
              'language': langName,
              'originalId': doc.id,
            };

            await _db.collection('stories').add(newData);
            translatedCount++;
            print('  ✓ Saved "$originalTitle" in $langName');
          } catch (e) {
            print('  ✗ Failed to translate "$originalTitle" to $langName: $e');
            // Continue with next translation instead of stopping everything
          }
        }
      }

      print('=== Translation complete! ===');
      print('Translated: $translatedCount | Skipped (already exists): $skippedCount');
    } catch (e) {
      print('Fatal error during translation: $e');
    }
  }
}
