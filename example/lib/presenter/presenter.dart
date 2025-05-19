import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:winc_dart_custom_lint/winc_dart_custom_lint.dart';

abstract class Presenter {
  final StreamController<String> _errorStreamController =
      StreamController<String>.broadcast();

  Stream<String> get errorStream => _errorStreamController.stream;

  @mustDispose
  Future<void> dispose() async {
    await _errorStreamController.close();
  }
}
