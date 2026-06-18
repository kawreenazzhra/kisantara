import 'package:flutter_test/flutter_test.dart';
import 'package:kisantara/services/storage_service.dart';

void main() {
  group('StorageService - buildSmartPrompt Tests', () {
    final storageService = StorageService();

    test('should return correct preset prompt for "Si Kancil dan Buaya"', () {
      final prompt = storageService.buildSmartPrompt('Si Kancil dan Buaya', 'FABEL');
      expect(
        prompt,
        contains('clever little mouse deer standing on the backs of crocodiles'),
      );
      // Ensure Indonesian title is not in the prompt
      expect(prompt, isNot(contains('Si Kancil dan Buaya')));
      expect(prompt, isNot(contains('called')));
    });

    test('should return correct preset prompt for "Danau Toba"', () {
      final prompt = storageService.buildSmartPrompt('Danau Toba', 'LEGENDA');
      expect(
        prompt,
        contains('massive volcanic lake with a green island in the middle, traditional Batak houses'),
      );
      expect(prompt, isNot(contains('Danau Toba')));
      expect(prompt, isNot(contains('called')));
    });

    test('should fallback correctly for unknown titles with keywords', () {
      final prompt = storageService.buildSmartPrompt('Putri Emas', 'DONGENG');
      // "putri" -> "princess", "emas" -> "golden gold"
      expect(prompt, contains('princess and golden gold'));
      expect(prompt, isNot(contains('Putri Emas')));
      expect(prompt, isNot(contains('called')));
    });

    test('should fallback to mythical character for unknown titles without keywords', () {
      final prompt = storageService.buildSmartPrompt('xyzabc', 'MITOS');
      expect(prompt, contains('mythical character'));
      expect(prompt, isNot(contains('xyzabc')));
      expect(prompt, isNot(contains('called')));
    });
  });
}
