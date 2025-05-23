// download_helper.dart
// Helper para download de arquivos no Flutter Web e Desktop

export 'download_helper_io.dart'
  if (dart.library.html) 'download_helper_web.dart';
