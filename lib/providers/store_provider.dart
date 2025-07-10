import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/count_down_manager.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/utils/constants/app_config.dart';

class StoreProvider with ChangeNotifier {
  final CountdownManager countdownManager;
  final AuthProvider authProvider;
  final SessionManager sessionManager;
  StoreProvider(
      {required this.authProvider,
      required this.countdownManager,
      required this.sessionManager});

  Future<Map<String, dynamic>> getStores(
      {required String? token, required String key, int page = 1}) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final Map<String, dynamic> body = {
      "keyword": key,
      "pageNumber": page,
      "pageSize": 10
    };
    final String endpoint = "${AppConfigs.baseUrl}/api/micro/moniback/mystores";

    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };
    final response = await http.post(
      Uri.parse(endpoint),
      headers: _headers,
      body: json.encode(body), // Convert body to JSON string
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        "success": true,
        "message": "Deals Fetched successfully",
        "data": jsonDecode(response.body)["data"],
      };
    } else {
      return {
        "success": false,
        "message": "Failed to fetch deals",
        "data": jsonDecode(response.body),
      };
    }
  }

  Future<Map<String, dynamic>> getStore(
      {required String? token, required String key}) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
     
    final String endpoint = "${AppConfigs.baseUrl}/api/micro/moniback/mystoreinfo?key=$key";

    print(endpoint);
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };
    final response = await http.get(
      Uri.parse(endpoint),
      headers: _headers,
      //body: json.encode(body), // Convert body to JSON string
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        "success": true,
        "message": "Deals Fetched successfully",
        "data": jsonDecode(response.body)["data"],
      };
    } else {
      return {
        "success": false,
        "message": "Failed to fetch deals",
        "data": jsonDecode(response.body),
      };
    }
  }

  Future<List<dynamic>> fetchBusinesses(
      {required String? token, String? filter}) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/mystores?page=1&filter=$filter";

    var response = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data["Monibacks"];
    } else {
      throw Exception("Failed to load businesses");
    }
  }

  Future<ImageProvider> fetchImage(
      {required String? token, required String url}) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return MemoryImage(response.bodyBytes);
    } else {
      throw Exception("Failed to load image");
    }
  }

  Future<Map<String, dynamic>> getStoreCreditBalance({
    required String? token,
    required String key,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/storecreditbalanceinfo?key=$key";

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body),
      };
    } else {
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<Map<String, dynamic>> point2StoreCredit({
    required String? token,
    required dynamic converDetails,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/convertpoint2credit";

    try {
      final response = await http.post(Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(converDetails));

      print(response.body);
      print("Got here ${response.statusCode.toString()}");
      if (response.statusCode == 200) {
       return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
      };
    } else {
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
    } catch (e) {
      return {
        "success": false,
        "data": "Failed to fetch deals",
       // "data": jsonDecode(response.body),
      };
    }
  }

}
