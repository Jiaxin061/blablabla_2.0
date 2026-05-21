import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/mock_farm_data.dart';
import '../constants/tag_constants.dart';
import 'tag_registry_service.dart';

final tagRegistryServiceProvider = Provider<TagRegistryService>((ref) {
  throw UnimplementedError('TagRegistryService must be overridden in main()');
});

class TagRegistryState {
  final Map<int, String> tagToRack;
  final bool isReady;

  const TagRegistryState({
    required this.tagToRack,
    this.isReady = false,
  });

  String? rackIdForTag(int tagId) => tagToRack[tagId];

  Map<String, dynamic>? rackDataForTag(int tagId) {
    final rackId = rackIdForTag(tagId);
    if (rackId == null) return null;
    return MockFarmData.rackById(rackId);
  }
}

class TagRegistryNotifier extends Notifier<TagRegistryState> {
  @override
  TagRegistryState build() {
    try {
      final service = ref.read(tagRegistryServiceProvider);
      final mappings = service.readAll();
      if (mappings.isNotEmpty) {
        return TagRegistryState(tagToRack: mappings, isReady: true);
      }
    } catch (_) {
      // Provider not overridden yet (e.g. tests).
    }
    return TagRegistryState(
      tagToRack: Map<int, String>.from(TagConstants.defaultTagToRack),
      isReady: true,
    );
  }

  Future<void> load() async {
    final service = ref.read(tagRegistryServiceProvider);
    state = TagRegistryState(tagToRack: service.readAll(), isReady: true);
  }

  Future<void> assignTag({required int tagId, required String rackId}) async {
    final service = ref.read(tagRegistryServiceProvider);
    await service.assignTag(tagId: tagId, rackId: rackId);
    state = TagRegistryState(
      tagToRack: service.readAll(),
      isReady: true,
    );
  }

  Future<void> resetToDefaults() async {
    for (final entry in TagConstants.defaultTagToRack.entries) {
      await assignTag(tagId: entry.key, rackId: entry.value);
    }
  }
}

final tagRegistryProvider =
    NotifierProvider<TagRegistryNotifier, TagRegistryState>(TagRegistryNotifier.new);
