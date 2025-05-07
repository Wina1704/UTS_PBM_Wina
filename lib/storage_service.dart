import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/activities.txt');
  }

  static Future<List<String>> readLines(String fileName) async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        return await file.readAsLines();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeLines(String fileName, List<String> lines) async {
    final file = await _localFile;
    await file.writeAsString(lines.join('\n'));
  }
}