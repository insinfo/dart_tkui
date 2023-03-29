# dart bindings to Tcl/Tk over FFI.

## Example:
```dart
import 'package:dart_tkui/src/tk_app_factory.dart';

void main() {
  var app = TkAppFactory('test')
      .create(pathToDll: 'C:/MyDartProjects/tkui/tcltk/bin');
  var count = 0;

  app.interp.createCommand('dart_tk_ui_Handler', (widgetsNames) {
    widgetsNames.forEach((name) {
      if (name == '.lbf1.b1') {
        print('you clicked the "$name button');
        app.interp.eval('.lbf1.lb1 configure -text {Press button $count}');
        count++;
      }
    });
    return 1;
  });
  app.interp.eval('wm title . "abcd"');
  app.interp.eval('wm geometry . 500x300');
  app.interp.eval('ttk::labelframe .lbf1 -text {Buttons}');
  app.interp.eval('ttk::label .lbf1.lb1 -text {Press button}');
  app.interp.eval('pack .lbf1.lb1 -side top -ipady 2');
  app.interp.eval('ttk::button .lbf1.b1 -text {Button 1}');
  app.interp.eval('.lbf1.b1 configure -command {dart_tk_ui_Handler .lbf1.b1}');

  app.interp.eval('pack .lbf1.b1 -side top');
  app.interp.eval(
      'pack .lbf1 -side left -ipadx 4 -ipady 4 -padx 4 -pady 2 -anchor n');

  app.run();
}

```


