/// AprilTag setup constants for demo (tag36h11 family).
abstract final class TagConstants {
  static const String tagFamily = 'tag36h11';
  static const List<int> demoTagIds = [0, 1, 2];

  /// Default mapping shipped with the app (editable in Rack Tags setup).
  static const Map<int, String> defaultTagToRack = {
    0: 'A',
    1: 'B',
    2: 'C',
  };

  /// Bundled tag images shown in Rack Tags setup.
  static const String apriltagsAssetDir = 'assets/images/apriltags/';

  static String assetPathForTagId(int tagId) =>
      '${apriltagsAssetDir}tag36h11_$tagId.png';

  static const Map<int, String> tagAssetPaths = {
    0: '${apriltagsAssetDir}tag36h11_0.png',
    1: '${apriltagsAssetDir}tag36h11_1.png',
    2: '${apriltagsAssetDir}tag36h11_2.png',
  };
}
