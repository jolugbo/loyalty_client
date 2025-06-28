import 'dart:async';
import 'package:flutter/foundation.dart';

class CountdownManager extends ChangeNotifier {
  static final CountdownManager _instance = CountdownManager._internal();
  factory CountdownManager() => _instance;
  CountdownManager._internal();

  static const int _initialSeconds = 3600;
  int _remainingSeconds = _initialSeconds;
  Timer? _timer;

  int get remainingSeconds => _remainingSeconds;

  void start() {
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _remainingSeconds = _initialSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void restart() {
    _resetTimer();
  }

  void disposeTimer() {
    _timer?.cancel();
  }
}
