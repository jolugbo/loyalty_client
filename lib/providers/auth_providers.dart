import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moniback/main.dart';
import 'package:moniback/modules/login.dart';
import 'package:moniback/providers/count_down_manager.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/utils/constants/app_config.dart';

class AuthProvider with ChangeNotifier {
  final SessionManager sessionManager;
  AuthProvider({required this.sessionManager});
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Function to log in
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final Map<String, String> body = {
      "username": username,
      "password": password,
      "scope": AppConfigs.scope,
      "grant_type": "password",
      "client_id": AppConfigs.clientId,
    };
      try {
    // Send the POST request with form-encoded body
    final response = await http.post(
      Uri.parse(AppConfigs.endpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body, // Form data is sent as key-value pairs
    );
    // Handle the response
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      CountdownManager().restart();
      return {
        "success": true,
        "access_token": jsonDecode(response.body)["access_token"],
        "refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["error_description"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["error_description"],
      };
    }
      }
      catch(e){
       return {
        "success": false,
        "data": "Something went wrong $e",
      };
      }
  }

  /// Function to log in
  Future<Map<String, dynamic>> create_account({
    required String username,
    required String firstname,
    required String lastname,
    required String email,
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/create-account";

    final Map<String, String> body = {
      "username": username,
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
    };
    print(body);
    // Send the POST request with form-encoded body
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );

    // Handle the response
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
      print("Got hereere 1");
      try{
    final response = await http.post(
      Uri.parse(AppConfigs.endpoint),
      body: {
        "grant_type": "refresh_token",
        "refresh_token": sessionManager.refreshToken,
        "client_id": AppConfigs.clientId,
        "scope": AppConfigs.scope,
      },
    );
      print("Got hereere");
//print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      sessionManager.updateTokens(
          accessToken: body["access_token"],
          refreshToken: body["refresh_token"]);
      return {
        "status": true,
      };
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
      return {
        "status": false,
      };
    }}
    catch(e){
      print("error here $e");
      return {
        "status": false,
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String username,
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/validate-email";
    final Map<String, String> body = {
      "email": username,
    };
    final response = await http.post(Uri.parse(endpoint),
        headers: {
          // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
    // print(response.statusCode);
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
        //"refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<Map<String, dynamic>> otp({
    required String email,
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/resend-otp";
    final Map<String, String> body = {
      "email": email,
    };
    final response = await http.post(Uri.parse(endpoint),
        headers: {
          // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
    // print(response.statusCode);
     print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
        //"refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,required String otp,
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/verify-otp";
    final Map<String, String> body = {
      "email": email,
      "otp": otp
    };
    final response = await http.post(Uri.parse(endpoint),
        headers: {
          // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
    // print(response.statusCode);
     print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
        //"refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

 Future<Map<String, dynamic>> createPassword({
    required String email,password
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/create-password";
    final Map<String, String> body = {
      "email": email,
       "password": password,
    };
    final response = await http.post(Uri.parse(endpoint),
        headers: {
          // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
     print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
        //"refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }


  Future<Map<String, dynamic>> forgotPass({
    required String email,
  }) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/account/forgot-password";
    final Map<String, String> body = {
      "email": email,
    };
    final response = await http.post(Uri.parse(endpoint),
        headers: {
          // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body));
     print(response.statusCode);
     print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      CountdownManager().restart();
      return {
        "success": true,
        "data": jsonDecode(response.body)["message"],
        //"refresh_token": jsonDecode(response.body)["refresh_token"],
      };
    } else {
      print(jsonDecode(response.body)["message"]);
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<String> getPin({required String token, bool isNew = false}) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/securepin";
    _headers["Authorization"] = "Bearer $token";
if (CountdownManager().remainingSeconds == 0) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
    var response;
    if (isNew) {
      response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
      );
    } else {
      response = await http.get(
        Uri.parse(endpoint),
        headers: _headers,
      );
    }

    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (isNew) {
        return data["data"];
      }

      return data["data"];
    } else {
      throw Exception("Failed to load businesses");
    }
  }
}
