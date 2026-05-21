import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/tag_constants.dart';

/// Tag credential returned by the (mock) generate API — stored as JSON for demo.
class TagCredential {
  final int tagId;
  final String family;
  final String rackId;
  final String farmId;
  final String farmName;
  final String issuedAt;
  final String credentialId;

  const TagCredential({
    required this.tagId,
    required this.family,
    required this.rackId,
    required this.farmId,
    required this.farmName,
    required this.issuedAt,
    required this.credentialId,
  });

  factory TagCredential.issue({
    required int tagId,
    required String rackId,
    DateTime? issuedAt,
  }) {
    final now = issuedAt ?? DateTime.now();
    return TagCredential(
      tagId: tagId,
      family: TagConstants.tagFamily,
      rackId: rackId.toUpperCase(),
      farmId: 'vblafarm-block-3a',
      farmName: 'vBlaFarm — Block 3A',
      issuedAt: now.toUtc().toIso8601String(),
      credentialId: const Uuid().v4().substring(0, 8).toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tagId': tagId,
        'family': family,
        'rackId': rackId,
        'farmId': farmId,
        'farmName': farmName,
        'issuedAt': issuedAt,
        'credentialId': credentialId,
        'assetPath': TagConstants.assetPathForTagId(tagId),
      };

  String toJsonPretty() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  static List<TagCredential> packFromMapping(Map<int, String> tagToRack) {
    return TagConstants.demoTagIds
        .map((id) => TagCredential.issue(tagId: id, rackId: tagToRack[id] ?? AppConstants.rackIds.first))
        .toList();
  }
}
