import 'dart:io';

Future<String?> saveCsvToFile(String filename, String csv) async {
  final path = '${Directory.systemTemp.path}/$filename';
  final file = File(path);
  await file.writeAsString(csv);
  return path;
}
