// ignore_for_file: avoid_print

import 'dart:ffi';
import 'dart:io';

import 'package:dart_tkui/src/tk_app_factory.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;

void main() {
  final stopwatch = Stopwatch()..start();
  // final libraryPath = path.join(Directory.current.path, 'pdfium.dll');
  // final dylib = DynamicLibrary.open(libraryPath);
  var app = TkAppFactory('Teste').create();
  

  app.interp.eval('toplevel .new_win');

  app.run();

  print('end: ${stopwatch.elapsed}');
}
