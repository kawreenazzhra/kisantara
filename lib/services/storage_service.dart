import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload byte data directly
  Future<String> uploadBytes(Uint8List bytes, String fileName, String mimeType) async {
    final ref = _storage.ref().child('story_covers').child(fileName);
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: mimeType),
    );
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Opens a file picker dialog and uploads the selected image to Firebase Storage.
  /// Returns the download URL, or null if the user cancelled.
  Future<String?> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Important for web — loads bytes directly
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return null;

      final ext = file.extension?.toLowerCase() ?? 'jpg';
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final fileName = 'cover_${DateTime.now().millisecondsSinceEpoch}.$ext';

      return await uploadBytes(bytes, fileName, mimeType);
    } catch (e) {
      print('Error picking/uploading image: $e');
      rethrow;
    }
  }

  // Upload a simulation asset (reads a local asset file and uploads it to Firebase Storage)
  Future<String> uploadSimulationAsset(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final fileName = 'simulated_${DateTime.now().millisecondsSinceEpoch}_${assetPath.split('/').last}';

      String mimeType = 'image/png';
      if (assetPath.endsWith('.jpg') || assetPath.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      return await uploadBytes(bytes, fileName, mimeType);
    } catch (e) {
      print('Error uploading simulation asset: $e');
      rethrow;
    }
  }
}
