import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/count_down_manager.dart';
import 'package:moniback/providers/session_manager.dart';
import 'dart:convert';

import 'package:moniback/utils/constants/app_config.dart';

class PromotionProvider with ChangeNotifier {
  List<dynamic> _deals = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;
  final CountdownManager countdownManager;
  final AuthProvider authProvider;
  final SessionManager sessionManager;
  PromotionProvider(
      {required this.authProvider,
      required this.countdownManager,
      required this.sessionManager});

  List<dynamic> get deals => _deals;
  bool get isLoading => _isLoading;
  bool get hasMorePages => _currentPage < _totalPages;

  Future<void> getDeals(
      {required String? token, bool isMyFavourites = false}) async {
    if (_isLoading || !hasMorePages) return;
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    _isLoading = true;
    notifyListeners();

    final String endpoint = "${AppConfigs.baseUrl}/api/micro/moniback/deals";
    final Map<String, String> headers = {"Authorization": "Bearer $token"};
    final Map<String, dynamic> body = {
      "businessKey": null,
      "isMyFavourites": isMyFavourites,
      "isLoadTotalRecord": true,
      "locationIds": [0],
      "currentUserId": null,
      "timezone": null,
      "dateformat": null,
      "keyword": null,
      "orderBy": null,
      "pageSize": 5,
      "pageNumber": _currentPage
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _totalPages = data["totalePages"];
        _deals.addAll(data["promotions"]);
        _currentPage++;
      } else {
        print("Error fetching deals: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
