import 'dart:ffi';
import 'dart:io';

import 'package:dart_tkui/dart_tkui.dart';

import 'package:path/path.dart' as path;

class TkAppFactory {
  static const LINUX_LIB_TCL = 'libtcl8.6.so';
  static const LINUX_LIB_TK = 'libtk8.6.so';

  static const WINDOWS_LIB_TCL = 'tcl86t.dll';
  static const WINDOWS_LIB_TK = 'tk86t.dll';

  static const DEFAULT_WIN_THEME = 'vista';
  static const DEFAULT_THEME = 'clam';

  String appName;

  TkAppFactory(this.appName) {}

  Tcl createTcl(String sharedLib) {
    final libraryPath = path.join("C:\\ActiveTcl\\bin", sharedLib);
    final dylib = DynamicLibrary.open(libraryPath);
    final tclBindings = TclBindings(dylib);
    final tclInstance = Tcl(tclBindings);
    return tclInstance;
  }

  Tk createTk(Interp tclInterp, String sharedLib) {
    //Directory.current.path
    final libraryPath = path.join("C:\\ActiveTcl\\bin", sharedLib);
    final dylib = DynamicLibrary.open(libraryPath);
    final tkBindings = TkBindings(dylib);
    final tkInstance = Tk(tkBindings, tclInterp);
    return tkInstance;
  }

  late Tcl tclInstance;
  late Interp interpInstance;
  late Tk tkInstance;

  TkApplication create() {
    tclInstance = createTcl(getDefaultTclLib());
    interpInstance = tclInstance.createInterp();
    tkInstance = createTk(interpInstance, getDefaultTkLib());
    var app = TkApplication(tkInstance, {'-name': appName});
    app.init();
    return app;
  }

  String getDefaultTclLib() {
    switch (Platform.operatingSystem) {
      case 'windows':
        return WINDOWS_LIB_TCL;
      case 'linux':
        return LINUX_LIB_TCL;
    }
    throw UnsupportedOSException();
  }

  String getDefaultTkLib() {
    switch (Platform.operatingSystem) {
      case 'windows':
        return WINDOWS_LIB_TK;

      case 'linux':
        return LINUX_LIB_TK;
    }

    throw UnsupportedOSException();
  }

  String getTheme(String theme) {
    return theme.toLowerCase() == 'auto'
        ? (Platform.isWindows ? DEFAULT_WIN_THEME : DEFAULT_THEME)
        : theme;
  }
}
