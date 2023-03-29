import 'dart:ffi';

import 'package:dart_tkui/dart_tkui.dart';
import 'package:ffi/ffi.dart';

typedef command_callback = Int32 Function(
    Pointer<Int32>, Pointer<Tcl_Interp>, Int32, Pointer<Pointer<Tcl_Obj>>);

/**
 * Low-level interface to Tcl FFI.
 */
class Tcl {
  /**
     * Command status codes.
     */
  static const TCL_OK = 0;
  static const TCL_ERROR = 1;
  static const TCL_RETURN = 2;
  static const TCL_BREAK = 3;
  static const TCL_CONTINUE = 4;

  /**
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/SetVar.htm#M5
     */
  static const TCL_GLOBAL_ONLY = 1;
  static const TCL_NAMESPACE_ONLY = 2;
  static const TCL_APPEND_VALUE = 4;
  static const TCL_LEAVE_ERR_MSG = 0x200;
  static const TCL_LIST_ELEMENT = 8;

  TclBindings ffi;

  Tcl(this.ffi) {}

  Interp createInterp() {
    var tclInterpPointer = ffi.Tcl_CreateInterp();
    var interpInstance = Interp(this, tclInterpPointer);
    return interpInstance;
  }

  void init(Interp interp) {
    var tclInterpPointer = interp.cdata();
    var status = ffi.Tcl_Init(tclInterpPointer);
    if (status != TCL_OK) {
      var errorMsg = nativeInt8ToString(ffi.Tcl_ErrnoMsg(ffi.Tcl_GetErrno()));
      throw TclException("Couldn't initialize Tcl interpretator. $errorMsg");
    }
  }

  /**
     * @param Interp $interp
     * @param String $script Tcl script.
     *
     * @return int Command status code.
     */
  int eval(Interp interp, String script) {
    var status = ffi.Tcl_Eval(interp.cdata(), stringToNativeInt8(script));
    if (status != TCL_OK) {
      throw EvalException(interp, script);
    }
    return status;
  }

  /**
     * Quote a string.
     *
     * When the String has [] characters it must be quoted otherwise
     * the data inside square brackets will be substituted by Tcl interp.
     */
  static String quoteString(String str) {
    return '{' + str + '}';
  }

  /**
     * Returns a String representation from Tcl_Obj structure.
     *
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/StringObj.htm
     */
  String getString(Pointer<Tcl_Obj> tclObj) {
    return nativeInt8ToString(ffi.Tcl_GetString(tclObj));
  }

  /**
     * Gets the Tcl eval result as a string.
     */
  String getStringResult(Interp interp) {
    return nativeInt8ToString(
        ffi.Tcl_GetString(ffi.Tcl_GetObjResult(interp.cdata())));
  }

  /**
     * Gets the Tcl eval result as a list of strings.
     *
     * @throws TclInterpException When FFI api call is failed.
     *
     * @return string[]
     */
  List<String> getListResult(Interp interp) {
    var listObj = this.ffi.Tcl_GetObjResult(interp.cdata());

    var len = this.getListLength(interp, listObj);
    if (len == 0) {
      return [];
    }

    var elements = <String>[];
    for (var index = 0; index < len; index++) {
      var elemObj = this.getListIndex(interp, listObj, index);
      elements.add(nativeInt8ToString(this.ffi.Tcl_GetString(elemObj)));
    }

    return elements;
  }

  ///
  /// Creates a new Tcl command for the specified interpreter.
  ///
  /// @param Interp $interp     The TCL interpreter.
  /// @param String $command    The command name.
  /// @param callable $callback The command
  ///
  /// Example:
  ///  https://github.com/thatchristoph/vmd-cvs-github/blob/ff3c1b70fd62600fa29ba79819f5312980939a2a/plugins/pmepot/src/tcl_pmepot.c
  ///  https://cpp.hotexamples.com/examples/-/-/Tcl_CreateObjCommand/cpp-tcl_createobjcommand-function-examples.html
  ///
  ///  callback.  function ($data, $interp, $objc, $objv)
  ///
  ///  int callback(ClientData nodata, Tcl_Interp *interp, int objc, Tcl_Obj *const objv[]) {}
  ///  Tcl_CreateObjCommand(interp,"pmepot_create",callback, (ClientData)NULL, (Tcl_CmdDeleteProc*)NULL);
  ///
  /// @link https://www.tcl.tk/man/tcl8.6/TclLib/CrtObjCmd.htm
  ///
  createCommand(Interp interp, String command,
      Pointer<NativeFunction<command_callback>> callback,
      {clientData}) {
    // TODO: check return value ?
    this.ffi.Tcl_CreateObjCommand(interp.cdata(), stringToNativeInt8(command),
        callback, clientData == null ? nullptr : clientData, nullptr);
  }

  /**
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/CrtObjCmd.htm
     * @throws TclInterpException When the command delete failed.
     */
  deleteCommand(Interp interp, String command) {
    if (this
            .ffi
            .Tcl_DeleteCommand(interp.cdata(), stringToNativeInt8(command)) ==
        -1) {
      throw new TclInterpException(interp, 'DeleteCommand');
    }
  }

  /**
     * Converts a PHP String to the Tcl object.
     */
  Pointer<Tcl_Obj> createStringObj(String str) {
    return this.ffi.Tcl_NewStringObj(stringToNativeInt8(str), str.length);
  }

  /**
     * Converts a PHP integer value to the Tcl object.
     */
  Pointer<Tcl_Obj> createIntObj(int i) {
    return this.ffi.Tcl_NewIntObj(i);
  }

  /**
     * Converts a PHP boolean value to the Tcl object.
     *  true == 1
     *  false == 0
     */
  Pointer<Tcl_Obj> createBoolObj(bool b) {
    return this.ffi.Tcl_NewBooleanObj(b == true ? 1 : 0);
  }

  /**
     * Converts a PHP float value to the Tcl object.
     */
  Pointer<Tcl_Obj> createFloatObj(double f) {
    return this.ffi.Tcl_NewDoubleObj(f);
  }

  createListObj() {
    return this.ffi.Tcl_NewListObj(0, nullptr);
  }

  String getStringFromObj(Pointer<Tcl_Obj> obj) {
    final lengthPtr = calloc<Int32>();
    return nativeInt8ToString(this.ffi.Tcl_GetStringFromObj(obj, lengthPtr));
  }

  int getIntFromObj(Interp interp, obj) {
    final longPtr = calloc<Int64>();
    if (this.ffi.Tcl_GetLongFromObj(interp.cdata(), obj, longPtr) != TCL_OK) {
      throw new TclInterpException(interp, 'GetLongFromObj');
    }
    return longPtr.value;
  }

  bool getBooleanFromObj(Interp interp, obj) {
    // $val = FFI::new('int');
    final val = calloc<Int32>();
    if (this.ffi.Tcl_GetBooleanFromObj(interp.cdata(), obj, val) != TCL_OK) {
      throw new TclInterpException(interp, 'GetBooleanFromObj');
    }
    return val.value == 1 ? true : false;
  }

  double getFloatFromObj(Interp interp, obj) {
    // $val = FFI::new('double');
    final val = calloc<Double>();
    if (this.ffi.Tcl_GetDoubleFromObj(interp.cdata(), obj, val) != TCL_OK) {
      throw new TclInterpException(interp, 'GetDoubleFromObj');
    }
    return val.value;
  }

  /**
     * @param mixed $value
     */
  void addListElement(Interp interp, listObj, value) {
    var obj = this.phpValueToObj(value);

    if (this.ffi.Tcl_ListObjAppendElement(nullptr, listObj, obj) != TCL_OK) {
      throw new TclInterpException(interp, 'Tcl_ListObjAppendElement');
    }
  }

  int getListLength(Interp interp, listObj) {
    //$len = FFI::new('int');
    final len = calloc<Int32>();
    if (this.ffi.Tcl_ListObjLength(interp.cdata(), listObj, len) != TCL_OK) {
      throw new TclInterpException(interp, 'ListObjLength');
    }
    return len.value;
  }

  getListIndex(Interp interp, listObj, int index) {
    //var result = this.ffi.new('Tcl_Obj*');
    var result = calloc<Pointer<Tcl_Obj>>();
    if (this.ffi.Tcl_ListObjIndex(interp.cdata(), listObj, index, result) !=
        TCL_OK) {
      throw new TclInterpException(interp, 'ListObjIndex');
    }
    return result;
  }

  /**
     * Converts a PHP value to Tcl Obj structure.
     *
     * @param string|int|float|bool|CData|null $value
     *
     * @throws TclException When a value cannot be converted to Tcl Obj.
     */
  phpValueToObj(value) {
    var obj;
    if (value is Pointer) {
      obj = value;
    } else if (value is String) {
      obj = this.createStringObj(value);
    } else if (value is int) {
      obj = this.createIntObj(value);
    } else if (value is double) {
      obj = this.createFloatObj(value);
    } else if (value is bool) {
      obj = this.createBoolObj(value);
    } else if (value == null) {
      obj = this.createStringObj('');
    } else {
      throw new TclException(
          'Failed to convert PHP value type "%s" to Tcl object value.' +
              value.runtimeType.toString());
    }

    return obj;
  }

  /**
     * @param String $varName The Tcl variable name.
     * @param string|NULL $arrIndex When the variable is an array that will be the array index.
     * @param string|int|float|bool|NULL|CData $value The variable value.
     *
     * @throws TclException      When value cannot be converted to the Tcl object.
     * @throws TclInterpException When FFI api call is failed.
     *
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/SetVar.htm
     */
  setVar(Interp interp, String varName, String? arrIndex, value) {
    var obj = this.phpValueToObj(value);
    var part1 = this.createStringObj(varName);
    var part2 = arrIndex != null ? this.createStringObj(arrIndex) : nullptr;
    var result = this
        .ffi
        .Tcl_ObjSetVar2(interp.cdata(), part1, part2, obj, TCL_LEAVE_ERR_MSG);
    if (result == nullptr) {
      throw new TclInterpException(interp, 'ObjSetVar2');
    }

    return result;
  }

  /**
     * @throws TclInterpException When FFI api call is failed.
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/SetVar.htm
     */
  getVar(Interp interp, String varName, [String? arrIndex]) {
    var part1 = this.createStringObj(varName);
    var part2 = arrIndex != null ? this.createStringObj(arrIndex) : nullptr;
    var result = this
        .ffi
        .Tcl_ObjGetVar2(interp.cdata(), part1, part2, TCL_LEAVE_ERR_MSG);
    if (result == nullptr) {
      throw new TclInterpException(interp, 'ObjGetVar2');
    }
    return result;
  }

  /**
     * @throws TclInterpException When FFI api call is failed.
     * @link https://www.tcl.tk/man/tcl8.6/TclLib/SetVar.htm
     */
  void unsetVar(Interp interp, String varName, [String? arrIndex]) {
    arrIndex = arrIndex == '' ? null : arrIndex;
    var result = this.ffi.Tcl_UnsetVar2(
        interp.cdata(),
        stringToNativeInt8(varName),
        arrIndex != null ? stringToNativeInt8(arrIndex) : nullptr,
        TCL_LEAVE_ERR_MSG);
    if (result != TCL_OK) {
      throw new TclInterpException(interp, 'UnsetVar2');
    }
  }

  /**
     * Converts a PHP array to a Tcl list.
     */
  static String arrayToList(List input) {
    return '{' + implode(' ', array_map(quoteString, input)) + '}';
  }

  /**
     * Formats String to Tcl option.
     *
     * The Tcl option is a lower case String with leading dash.
     */
  static String strToOption(String name) {
    return '-' + name.toLowerCase();
  }
}
