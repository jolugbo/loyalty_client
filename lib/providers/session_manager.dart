import 'package:flutter/material.dart';

class SessionManager extends ChangeNotifier {
 String? _authToken;
  String? _refreshToken;

  String? get authToken => _authToken;
  String? get refreshToken => _refreshToken;

  void updateToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  void updateTokens({required String accessToken, required String refreshToken}) {
    _authToken = accessToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }
 
}
