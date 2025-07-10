import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moniback/providers/auth_providers.dart';
import 'package:moniback/providers/count_down_manager.dart';
import 'package:moniback/providers/session_manager.dart';
import 'package:moniback/utils/constants/app_config.dart';
import 'package:moniback/utils/constants/app_images.dart';

class VoucherProvider with ChangeNotifier {
  final CountdownManager countdownManager;
  final AuthProvider authProvider;
  final SessionManager sessionManager;
  VoucherProvider(
      {required this.authProvider,
      required this.countdownManager,
      required this.sessionManager});
  // final Map<String, String> _headers = {
  //   "Content-Type": "application/json",
  //   "Accept": "application/json",
  // };

  Future<Map<String, dynamic>> getDeals(
      {required String? token,
      String search = "",
      bool isMyFavourites = false,
      int page = 1}) async {
    final String endpoint = "${AppConfigs.baseUrl}/api/micro/moniback/deals";

    print(
        "CountdownManager().remainingSeconds ${CountdownManager().remainingSeconds}");
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };
    // final Map<String, String> _headers = {
    //   'content-type': 'application/json',
    //   "Authorization": "Bearer $token",
    // };
    //_headers["Authorization"] = "Bearer $token";

    final Map<String, dynamic> body = {
      "businessKey": null,
      "isMyFavourites": isMyFavourites,
      "isLoadTotalRecord": true,
      "locationIds": [0],
      "currentUserId": null,
      "timezone": null,
      "dateformat": null,
      "keyword": search,
      "orderBy": null,
      "pageSize": 100,
      "pageNumber": page
    };
    print(body);

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body), // Convert body to JSON string
      );
      print(response.headers);
      // Handle response
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
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> getBulkDeals({
    required String? token,
    required String key,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/deals/bulk?promotionKey=$key";
    print(endpoint);
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body)["data"],
      };
    } else {
      return {
        "success": false,
        "data": jsonDecode(response.body)["message"],
      };
    }
  }

  Future<Map<String, dynamic>> getConversionHistory(
      {required String? token,
      String search = "",
      bool isMyFavourites = false,
      int page = 1}) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/conversion-history";

    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };

    final Map<String, dynamic> body = {
      "keyword": "",
      "pageNumber": 1,
      "pageSize": 100
    };
    print(body);

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body), // Convert body to JSON string
      );
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": "History Fetched successfully",
          "data": jsonDecode(response.body)["data"],
        };
      } else {
        return {
          "success": false,
          "message": "Failed to fetch History",
          "data": jsonDecode(response.body),
        };
      }
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> getMyDeals(
      {required String? token,
      String search = "",
      bool isExpired = false,
      isRedeemed = false,
      int page = 1}) async {
    final String endpoint = "${AppConfigs.baseUrl}/api/micro/moniback/mydeals";

    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };

    // final Map<String, String> _headers = {
    //   'content-type': 'application/json',
    //   "Authorization": "Bearer $token",
    // };
    //_headers["Authorization"] = "Bearer $token";

    final Map<String, dynamic> body = {
      'isRedeemed': isRedeemed,
      'isExpired': isExpired,
      'keyword': search,
      'pageNumber': page,
      'pageSize': 13
    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body), // Convert body to JSON string
      );
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print(jsonDecode(response.body));
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
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> getDealsByLocation(
      {required String? token,
      required String? longitude,
      required String? latitude,
      String search = "",
      bool isMyFavourites = false,
      int page = 1}) async {
    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/deals/location";

    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Authorization": "Bearer $token"
    };
    // final Map<String, String> _headers = {
    //   'content-type': 'application/json',
    //   "Authorization": "Bearer $token",
    // };
    //_headers["Authorization"] = "Bearer $token";

    final Map<String, dynamic> body = {
      "businessKey": null,
      "isMyFavourites": false,
      "isLoadTotalRecord": true,
      "locationIds": [0],
      "keyword": null,
      "orderBy": null,
      "latitude": latitude,
      "longitude": longitude,
      "pageNumber": page,
      "pageSize": 10
    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body), // Convert body to JSON string
      );
      print(response.headers);
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        print(jsonDecode(response.body));
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
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> claimDeal(
      {required String? token,
      required String businessKey,
      required String PromotionKey}) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }

    final String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/voucher/claim";
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };

    final Map<String, dynamic> body = {
      "businessKey": businessKey,
      "PromotionKey": PromotionKey
    };

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(endpoint),
        headers: _headers,
        body: json.encode(body), // Convert body to JSON string
      );

      print("Got here ${response.statusCode.toString()}");
      print("Got here ${jsonDecode(response.body)}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": "Deal Claimed successfully",
          "data": jsonDecode(response.body),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to Claim deals",
          "data": jsonDecode(response.body)["Message"],
        };
      }
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> bookMarkVoucher({
    required String? token,
    required String promotionkey,
    required bool bookmark,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/voucher/bookmark?promotionkey=$promotionkey";
    if (!bookmark) {
      endpoint =
          "${AppConfigs.baseUrl}/api/micro/moniback/voucher/unbookmark?promotionkey=$promotionkey";
    }
    final Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    };
    try {
      // Send the POST request
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _headers,
      );

      print(response.body);
      print("Got here ${response.statusCode.toString()}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": " bookmark action successful",
          //"data": jsonDecode(response.body),
        };
      } else {
        return {
          "success": false,
          "message": "Failed, bookmark action unsuccessful",
          // "data": jsonDecode(response.body),
        };
      }
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> likeVoucher({
    required String? token,
    required String promotionkey,
    required String businessKey,
    required bool like,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }
    String endpoint =
        "${AppConfigs.baseUrl}/api/micro/moniback/voucher/like?promotionkey=$promotionkey";
    if (!like) {
      endpoint =
          "${AppConfigs.baseUrl}/api/micro/moniback/voucher/unlike?promotionkey=$promotionkey";
    }
    final Map<String, String> _headers = {
      "Authorization": "Bearer $token",
    };

    try {
      print(endpoint);
      // Send the POST request
      final response = await http.get(
        Uri.parse(endpoint),
        headers: _headers,
      );
      print(jsonDecode(response.body));
      print("Got here ${response.statusCode.toString()}");
      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "message": " Like action successful",
          //"data": jsonDecode(response.body),
        };
      } else {
        return {
          "success": false,
          "message": "Failed, Like action unsuccessful",
          // "data": jsonDecode(response.body),
        };
      }
    } catch (e) {
      print("Failed here......................... $e");
      return {
        "success": false,
        "message": "An error occurred: $e",
        "data": null,
      };
    }
  }

  Future<ImageProvider> getImage({
    required String? token,
    required String imageUrl,
  }) async {
    if (CountdownManager().remainingSeconds == 0) {
      await authProvider.refreshToken();
      countdownManager.restart();
      token = sessionManager.authToken;
    }

    final Map<String, String> _headers = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $token",
    };
    try {
      // Send the POST request
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: _headers,
      );
      print("Got here ${response.statusCode.toString()}");

      // Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        return MemoryImage(response.bodyBytes);
      } else {
        throw Exception("Failed to load image");
      }
    } catch (e) {
      print("Failed here......................... $e");
      // Return the placeholder image from assets if fetching fails
      return AssetImage(AppImages.deal);
    }
  }
}
