import 'dart:ffi';

import 'package:dart_tkui/dart_tkui.dart';

/**
 * Low-level interface to Tk FFI.
 */
class Tk {
  TkBindings ffi;
  late Pointer<Tcl_Interp> tkInterp;
  Interp tclInterp;

  /**
     * @param FFI    $ffi    FFI to Tk library.
     * @param Interp $interp Tcl interpreter.
     */
  Tk(this.ffi, this.tclInterp) {
    this.tkInterp = tclInterp.cdata();
  }

  void init() {
    if (this.ffi.Tk_Init(this.tkInterp) != Tcl.TCL_OK) {
      //var errorMsg = nativeInt8ToString(ffi.Tcl_ErrnoMsg(ffi.Tcl_GetErrno()));
      throw TclException("Couldn't init Tk library.");
    }
  }

  void mainLoop() {
    this.ffi.Tk_MainLoop();
  }

  Interp interp() {
    return this.tclInterp;
  }

  mainWindow() {
    var tkWin = this.ffi.Tk_MainWindow(this.tkInterp);
    return tkWin;
  }

  destroy(win) {
    this.ffi.Tk_DestroyWindow(win);
  }

  nameToWindow(String pathName, win) {
    this.ffi.Tk_NameToWindow(this.tkInterp, stringToNativeInt8(pathName), win);
  }
}
