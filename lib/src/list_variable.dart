import 'dart:ffi';

import 'package:dart_tkui/dart_tkui.dart';

class ListVariable {
   Interp _interp;
   late Pointer _listObj;
   String _name;

  ListVariable(this._interp, this._name) {
    _listObj = _interp.tcl().createListObj();
    _interp.tcl().setVar(_interp, _name, null, _listObj);
  }

  String name() {
    return _name;
  }

  ListVariable append(List values) {
    for (var value in values) {
      _interp.tcl().addListElement(_interp, _listObj, value);
    }
    return this;
  }

  int count() {
    return _interp.tcl().getListLength(_interp, _listObj);
  }

  index(int i) {
    var result = _interp.tcl().getListIndex(_interp, _listObj, i);
    return _interp.tcl().getStringFromObj(result);
  }
}
