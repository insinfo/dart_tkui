import 'dart:ffi';

import 'package:dart_tkui/dart_tkui.dart';

class Interp {
  Tcl _tcl;
  Pointer<Tcl_Interp> _interp;
  ListVariable? _argv;

  Interp(this._tcl, this._interp) {}

  /**
     * Initializes Tcl interpreter.
     */
  void init() {
    debug('Interp@init: start interp initialize');
    _tcl.init(this); 
    this._argv = this.createListVariable('argv');
    debug('Interp@init: end interp initialize');
  }

  /// return Pointer to Tcl_Interp
  Pointer<Tcl_Interp> cdata() {
    return _interp;
  }

  /**
     * @throws LogicException When interp is not initialized.
     */
  ListVariable argv() {
    if (_argv == null) {
      throw new LogicException('Interp not initialized.');
    }
    return _argv!;
  }

  /**
     * Creates a Tcl list variable.
     */
  ListVariable createListVariable(String varName) {
    debug('Interp@createListVariable', {'varName': varName});
    return ListVariable(this, varName);
  }

  /**
     * Gets the string result of the last executed command.
     */
  String getStringResult() {
    return _tcl.getStringResult(this);
  }

  /**
     * Evaluates a Tcl script.
     */
  void eval(String script) {
    debug('Interp@eval', {'script': script});
    _tcl.eval(this, script);
  }

  Tcl tcl() {
    return _tcl;
  }

  //$data, $interp, $objc, $objv
  static int _callback(Pointer<Int32> data, Pointer<Tcl_Interp> interp,
      int objc, Pointer<Pointer<Tcl_Obj>> objv) {
    // var params = [];
    // for (var i = 1; i < objc; i++) {
    // params.add(_tcl.getString(objv[i]));
    // }
    //callback(...params);
    debug('_callback');
    return 0;
  }

  static const exceptionalReturn = -1;

  /**
     * Creates a Tcl command.
     */
  createCommand(String command, Function callback) {
    debug('createCommand', {'command': command});
    _tcl.createCommand(
      this,
      command,
      Pointer.fromFunction<command_callback>(_callback, exceptionalReturn),
    );
  }
}
