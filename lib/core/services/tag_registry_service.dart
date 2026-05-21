import 'package:hive_flutter/hive_flutter.dart';
import '../constants/tag_constants.dart';
import '../constants/app_constants.dart';

/// Persists AprilTag ID → rack ID mappings locally for demo.
class TagRegistryService {
  TagRegistryService(this._box);

  final Box<String> _box;

  static Future<TagRegistryService> open() async {
    final box = await Hive.openBox<String>(AppConstants.hiveBoxTagRegistry);
    final service = TagRegistryService(box);
    await service._seedDefaultsIfEmpty();
    return service;
  }

  Future<void> _seedDefaultsIfEmpty() async {
    if (_box.isNotEmpty) return;
    for (final entry in TagConstants.defaultTagToRack.entries) {
      await _box.put(_key(entry.key), entry.value);
    }
  }

  Map<int, String> readAll() {
    final result = <int, String>{};
    for (final tagId in TagConstants.demoTagIds) {
      final rackId = _box.get(_key(tagId));
      if (rackId != null) result[tagId] = rackId;
    }
    return result;
  }

  String? rackIdForTag(int tagId) => _box.get(_key(tagId));

  Future<void> assignTag({required int tagId, required String rackId}) async {
    await _box.put(_key(tagId), rackId.toUpperCase());
  }

  static String _key(int tagId) => 'tag_$tagId';
}
