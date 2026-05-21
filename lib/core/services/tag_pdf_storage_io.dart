import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

String? tagPdfLastSaveDirectory;

String tagPdfSaveFolderLabel() {
  if (tagPdfLastSaveDirectory == null) return 'Downloads/vBlaFarm/tags';
  final dir = tagPdfLastSaveDirectory!;
  if (dir.contains('Download')) return 'Downloads/vBlaFarm/tags';
  if (dir.contains('Documents')) return 'Documents/vBlaFarm/tags';
  return 'vBlaFarm/tags';
}

Future<Directory> _ensureDirectory() async {
  Directory base;
  if (Platform.isAndroid || Platform.isIOS) {
    final downloads = await getDownloadsDirectory();
    base = downloads ?? await getApplicationDocumentsDirectory();
  } else {
    base = await getApplicationDocumentsDirectory();
  }
  final dir = Directory('${base.path}/vBlaFarm/tags');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  tagPdfLastSaveDirectory = dir.path;
  return dir;
}

Future<String> savePdfBytes(Uint8List bytes, String filename) async {
  final dir = await _ensureDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
