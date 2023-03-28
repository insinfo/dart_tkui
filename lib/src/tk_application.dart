// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_tkui/dart_tkui.dart';

class TkApplication {
  Tk tk;
  late Interp interp;

  Map<String, dynamic> _argv = {};

  TkApplication(this.tk, this._argv) {
    this.interp = tk.interp();
  }

  /**
     * Initializes Tcl and Tk libraries.
     */
  void init() {
    interp.init();
    setInterpArgv();
    tk.init();
    initTtk();
  }

  /**
     * Initialization of ttk package.
     */
  void initTtk() {
    try {
      interp.eval('package require Ttk');
      //themeManager = $this->createThemeManager();
    } on TclInterpException catch (e) {
      debug('TclInterpException package ttk is not found');
      // TODO: ttk must be required ?
      // $this->themeManager = null;
      //this.info('package ttk is not found');
    }
  }

  void setInterpArgv() {
    for (var item in _argv.entries) {
      interp.argv().append([item.key, item.value]);
    }
  }

  /**
     * Application's the main loop.
     *
     * Will process all the app events.
     */
  void run() {
    debug('TkApplication@run');
    tk.mainLoop();
  }

  void quit() {
    debug('TkApplication@destroy');
    tclEval(['destroy', '.']);
  }

  /**
     * @inheritdoc
     */
  String tclEval(List args) {
    // TODO: to improve performance not all the arguments should be quoted
    // but only those which are parameters. But this requires a new method
    // like this: tclCall($command, $method, ...$args)
    // and only $args must be quoted.
    var script = implode(' ', array_map((arg) => encloseArg(arg), args));
    interp.eval(script);

    return interp.getStringResult();
  }

  /**
     * Encloses the argument in the curly brackets.
     *
     * This function automatically detects when the argument
     * should be enclosed in curly brackets.
     *
     * @see App::tclEval()
     *
     * @param mixed $arg
     */
  String encloseArg(arg) {
    if (arg is String) {
      var chr = arg[0];
      if (chr == '"' || chr == "'" || chr == '{' || chr == '[') {
        return arg;
      }
      return (arg.indexOf(' ') == -1 && arg.indexOf("\n") == -1)
          ? arg
          : Tcl.quoteString(arg);
    } else if (arg is List) {
      // TODO: deep into $arg to check nested array.
      arg = '{' + implode(' ', arg) + '}';
    }
    return arg;
  }
}
