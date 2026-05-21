import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/mock_farm_data.dart';
import '../constants/tag_constants.dart';
import '../models/tag_credential.dart';
import 'tag_generate_service.dart';
import 'tag_registry_service.dart';

final tagRegistryServiceProvider = Provider<TagRegistryService>((ref) {
  throw UnimplementedError('TagRegistryService must be overridden in main()');
});

class TagRegistryState {
  final Map<int, String> tagToRack;
  final Map<int, TagCredential> credentials;
  final bool isReady;
  final bool isGenerating;
  final bool hasGeneratedPack;

  const TagRegistryState({
    required this.tagToRack,
    this.credentials = const {},
    this.isReady = false,
    this.isGenerating = false,
    this.hasGeneratedPack = false,
  });

  TagRegistryState copyWith({
    Map<int, String>? tagToRack,
    Map<int, TagCredential>? credentials,
    bool? isReady,
    bool? isGenerating,
    bool? hasGeneratedPack,
    bool clearCredentials = false,
  }) {
    return TagRegistryState(
      tagToRack: tagToRack ?? this.tagToRack,
      credentials: clearCredentials ? {} : (credentials ?? this.credentials),
      isReady: isReady ?? this.isReady,
      isGenerating: isGenerating ?? this.isGenerating,
      hasGeneratedPack: clearCredentials ? false : (hasGeneratedPack ?? this.hasGeneratedPack),
    );
  }

  String? rackIdForTag(int tagId) => tagToRack[tagId];

  TagCredential? credentialForTag(int tagId) => credentials[tagId];

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
    state = state.copyWith(tagToRack: service.readAll(), isReady: true);
  }

  Future<void> assignTag({required int tagId, required String rackId}) async {
    final service = ref.read(tagRegistryServiceProvider);
    await service.assignTag(tagId: tagId, rackId: rackId);
    final updated = service.readAll();
    final creds = Map<int, TagCredential>.from(state.credentials);
    if (creds.containsKey(tagId)) {
      creds[tagId] = TagCredential.issue(tagId: tagId, rackId: rackId);
    }
    state = state.copyWith(tagToRack: updated, credentials: creds);
  }

  /// Mock POST /tags/generate — returns JSON credentials for current mapping.
  Future<void> generateCredentials() async {
    if (state.isGenerating) return;
    state = state.copyWith(isGenerating: true);
    try {
      final pack = await TagGenerateService.generatePack(state.tagToRack);
      final creds = {for (final c in pack) c.tagId: c};
      state = state.copyWith(
        isGenerating: false,
        credentials: creds,
        hasGeneratedPack: true,
      );
    } catch (_) {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> resetToDefaults() async {
    for (final entry in TagConstants.defaultTagToRack.entries) {
      await assignTag(tagId: entry.key, rackId: entry.value);
    }
    state = state.copyWith(clearCredentials: true);
  }
}

final tagRegistryProvider =
    NotifierProvider<TagRegistryNotifier, TagRegistryState>(TagRegistryNotifier.new);
