import 'dart:ffi';

import 'package:dart_tkui/dart_tkui.dart';
import 'package:ffi/ffi.dart';

class Interp {
  Tcl _tcl;
  Pointer<Tcl_Interp> _interp;
  ListVariable? _argv;

  Interp(this._tcl, this._interp) {
    _commands = [];
  }

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

  Tcl tcl() {
    return _tcl;
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

  static List<Map<String, Function(List<String> widgets)>> _commands = [];

  static int _callback(Pointer<Int32> data, Pointer<Tcl_Interp> interp,
      int objc, Pointer<Pointer<Tcl_Obj>> objv) {
    var widgetsNames = <String>[];
    for (var i = 1; i < objc; i++) {
      widgetsNames.add(objv.elementAt(i).value.ref.asString());
    }

    _commands.forEach((element) {
      element.values.first(widgetsNames);
    });
   
    return 0;
  }

  static const exceptionalReturn = -1;

  ///
  /// Creates a Tcl command.
  ///
  /// TR - This C function is used to create a new command usable from the Tcl script level. The definition is
  ///
  /// Tcl_Command Tcl_CreateObjCommand(interp, cmdName, proc, clientData, deleteProc)
  /// so it returns a Tcl_Command (which is a token for the command) and takes 5 arguments:
  ///
  /// interp - the interpreter in which to create the new command
  /// cmdName - the name of the new command (possibly in a specific namespace)
  /// proc - the name of a C function to handle the command execution when called by a script
  /// clientData - some data associated with the command, when a state needs to be taken care of (a file for example);
  /// this is typically used where a proc is used to create a whole family of commands, such as the instances of a kind of Tk widget.
  /// deleteProc - a C function to call when the command is deleted from the interpreter
  /// (used for cleanup of the clientData) which may be NULL if no cleanup is needed.
  /// A full example of the usage can be found in: Hello World as a C extension.
  /// Here is an example from the sqlite extension used to create the 'sqlite' command:
  /// https://wiki.tcl-lang.org/page/Tcl_CreateObjCommand
  createCommand(String commandName, Function(List<String> widgets) callback) {
    debug('createCommand', {'command': commandName});

    _commands.add({commandName: callback});

    _tcl.createCommand(
      this,
      commandName,
      Pointer.fromFunction<command_callback>(_callback, exceptionalReturn),
    );
  }
}
