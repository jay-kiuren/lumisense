import 'csv_export_stub.dart'
    if (dart.library.html) 'csv_export_web.dart'
    if (dart.library.io) 'csv_export_io.dart' as csv_impl;

Future<String?> saveCsvToFile(String filename, String csv) =>
    csv_impl.saveCsvToFile(filename, csv);
