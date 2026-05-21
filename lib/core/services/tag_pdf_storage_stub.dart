import 'dart:typed_data';

String? tagPdfLastSaveDirectory;

String tagPdfSaveFolderLabel() => 'device storage';

Future<String> savePdfBytes(Uint8List bytes, String filename) async {
  throw UnsupportedError('Auto-save PDF is only available on Android and iOS.');
}
