import 'dart:io';

import 'package:dart_tkui/dart_tkui.dart';

class TclException implements Exception {
  /// A message describing the error.
  String? message = '';
  TclException([this.message = 'TclException']);

  @override
  String toString() {
    return 'TclException: $message';
  }
}

class TclInterpException extends TclException {
  late Interp interp;
  late String result;

  TclInterpException(Interp interp, String message)
      : super(message + ': ' + interp.getStringResult()) {
    this.result = interp.getStringResult();
    this.interp = interp;
  }

  Interp getInterp() {
    return this.interp;
  }

  String getStringResult() {
    return this.result;
  }

  @override
  String toString() {
    return 'TclInterpException: $message $result';
  }
}

class LogicException implements Exception {
  String? message = '';
  LogicException([this.message = 'LogicException']);
}

class EvalException extends TclInterpException {
  late String script;

  EvalException(Interp interp, String script) : super(interp, 'Eval') {
    this.script = script;
  }

  String getScript() {
    return this.script;
  }
}

/// An exception class that's thrown when a pdfium operation is unable to be
/// done correctly.
class TkException implements Exception {
  /// Error code of the exception
  int? errorCode;

  /// A message describing the error.
  String? message = '';

  /// Default constructor of PdfiumException
  TkException({this.message});

  /// Factory constructor to create a FileException with an error code
  factory TkException.fromErrorCode(int errorCode) {
    final e = FileException();
    e.errorCode = errorCode;
    return e;
  }

  @override
  String toString() {
    // ignore: no_runtimetype_tostring
    return '$runtimeType: $errorCode | $message';
  }
}

class UnknownException extends TkException {
  UnknownException({String? message}) : super(message: message);
}

class UnsupportedOSException implements Exception {
  String? message = '';
  UnsupportedOSException() {
    message = 'Unsupported OS: ' + Platform.operatingSystem;
  }

  @override
  String toString() {
    return 'UnsupportedOSException: $message';
  }
}

class FileException extends TkException {
  FileException({String? message}) : super(message: message);
}

class FormatException extends TkException {
  FormatException({String? message}) : super(message: message);
}

class PasswordException extends TkException {
  PasswordException({String? message}) : super(message: message);
}

class SecurityException extends TkException {
  SecurityException({String? message}) : super(message: message);
}

class PageException extends TkException {
  PageException({String? message}) : super(message: message);
}
