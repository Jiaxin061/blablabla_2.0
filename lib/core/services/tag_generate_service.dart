import '../models/tag_credential.dart';

/// Mock tag generate API — simulates backend issuing credentials (JSON).
class TagGenerateService {
  static const Duration apiDelay = Duration(milliseconds: 1400);

  static Future<List<TagCredential>> generatePack(Map<int, String> tagToRack) async {
    await Future.delayed(apiDelay);
    return TagCredential.packFromMapping(tagToRack);
  }
}
