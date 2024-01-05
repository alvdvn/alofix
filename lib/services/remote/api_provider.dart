import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:base_project/common/constance/strings.dart';
import 'package:base_project/common/utils/alert_dialog_utils.dart';
import 'package:base_project/common/utils/progress_h_u_d.dart';
import 'package:base_project/config/routes.dart';
import 'package:base_project/environment.dart';
import 'package:base_project/models/base_model/server_response.dart';
import 'package:get/get.dart';

// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:g_json/g_json.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthenticationKey {
  static final shared = AuthenticationKey();
  String token = '';
}

class ApiProvider {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  final codeNoInternet = 700;
  static const _timeOut = 60;
  final codeTimeOut = 504;
  final commonCode = 10000;
  final Uri uriLink = Uri.parse('njvcall://vn.etelecom.njvcall');

  Map errorResponse(String message, int code) {
    return ServerResponse(message: message, statusCode: code).toJson();
  }

  Future<JSON> get(String url,
      {required Map<String, dynamic> params,
      bool isRequireAuth = false,
      bool backgroundMode = false}) async {
    try {
      final token = AuthenticationKey.shared.token;
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);
      if (isRequireAuth) {
        header.addAll({
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "x-version": '$currentVersion'
        });
      } else {
        print('x-version NO AUTHEN POST $currentVersion');
        header.addAll({"x-version": '$currentVersion'});
      }
      final queryString = Uri(queryParameters: params).query;
      debugPrint(
          'API log code: ${Environment.getServerUrl()}$url${'?$queryString'}');
      final response = await http
          .get(
            Uri.parse('${Environment.getServerUrl()}$url'),
            headers: header,
          )
          .timeout(const Duration(seconds: _timeOut));
      debugPrint('API log code: ${response.statusCode}');
      final responseJson = _response(response);
      return responseJson;
    } catch (e, r) {
      debugPrint('$r');
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, codeNoInternet));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(e.toString(), commonCode));
      }
    }
  }

  Future<JSON> post(String url, Map<String, dynamic> params,
      {bool isRequireAuth = false, bool backgroundMode = false}) async {
    final token = AuthenticationKey.shared.token;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = int.parse(packageInfo.buildNumber);
    if (isRequireAuth) {
      print('x-version POST $currentVersion');
      header.addAll({
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "x-version": '$currentVersion'
      });
    } else {
      print('x-version NO AUTHEN POST $currentVersion');
      header.addAll({"x-version": '$currentVersion'});
    }
    try {
      if (backgroundMode == true) {
        ProgressHUD.show();
      }
      final body = jsonEncode(params);
      debugPrint("url ${Environment.getServerUrl() + url}");
      final response = await http
          .post(Uri.parse(Environment.getServerUrl() + url),
              body: body, headers: header)
          .timeout(const Duration(seconds: _timeOut));
      final responseJson =
          _response(response, isBackgroundMode: backgroundMode);
      ProgressHUD.dismiss();
      return responseJson;
    } catch (e) {
      ProgressHUD.dismiss();
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, codeNoInternet));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(e.toString(), commonCode));
      }
    }
  }

  Future<JSON> postListString(
      String url, final List<Map<String, dynamic>> params,
      {bool isRequireAuth = false, bool backgroundMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenShare = prefs.getString('access_token');
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = int.parse(packageInfo.buildNumber);
    if (isRequireAuth) {
      header.addAll({
        HttpHeaders.authorizationHeader: 'Bearer $tokenShare',
        "x-version": '$currentVersion'
      });
    }
    try {
      final body = jsonEncode(params);
      debugPrint("url post ${Environment.getServerUrl() + url}");
      final response = await http
          .post(Uri.parse(Environment.getServerUrl() + url),
              body: body, headers: header)
          .timeout(const Duration(seconds: _timeOut));
      final responseJson = JSON.parse(response.body);
      debugPrint("url post status ${response.statusCode} body ${responseJson}");
      return responseJson;
    } catch (e) {
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, codeNoInternet));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(e.toString(), commonCode));
      }
    }
  }

  Future<JSON> put(String url, Map<String, dynamic> params,
      {bool isRequireAuth = false}) async {
    if (isRequireAuth) {
      final token = AuthenticationKey.shared.token;
      header.addAll({HttpHeaders.authorizationHeader: 'Bearer $token'});
    }
    try {
      ProgressHUD.show();
      debugPrint('Call API: $url}');
      final query = jsonEncode(params);
      debugPrint('API log query: $query');
      final response = await http
          .put(Uri.parse(Environment.getServerUrl() + url),
              body: jsonEncode(params), headers: header)
          .timeout(const Duration(seconds: _timeOut));
      debugPrint('API log: ${response.request}');

      final responseJson = _response(response);
      return responseJson;
    } catch (e) {
      ProgressHUD.dismiss();
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, codeNoInternet));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(e.toString(), commonCode));
      }
    }
  }

  Future<JSON> delete(String url, {bool isRequireAuth = true}) async {
    if (isRequireAuth) {
      final token = AuthenticationKey.shared.token;
      header.addAll({HttpHeaders.authorizationHeader: 'Bearer $token'});
    }
    try {
      ProgressHUD.show();
      final response = await http
          .delete(Uri.parse(Environment.getServerUrl() + url), headers: header)
          .timeout(const Duration(seconds: _timeOut));
      debugPrint('API log: ${response.request}');
      debugPrint('API log code: ${response.statusCode}');

      final responseJson = _response(response);
      return responseJson;
    } catch (e) {
      ProgressHUD.dismiss();
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, commonCode));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(e.toString(), commonCode));
      }
    }
  }

  Future<JSON> uploadFile(File file) async {
    final token = AuthenticationKey.shared.token;
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'multipart/form-data',
      HttpHeaders.acceptEncodingHeader: 'accept: application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.connectionHeader: 'keep-alive'
    };
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('${Environment.getServerUrl()}/common/upload'));
      request.headers.addAll(headers);
      final fileDAta = await http.MultipartFile.fromPath('file', file.path,
              contentType: parser.MediaType('image', 'png'))
          .timeout(const Duration(seconds: _timeOut));
      request.files.add(fileDAta);
      final requestResponse = await request.send();
      final responseString = await requestResponse.stream.bytesToString();
      final jsonResponse = JSON.parse(responseString);
      return jsonResponse;
    } catch (e) {
      ProgressHUD.dismiss();
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, commonCode));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(
            e.toString(), commonCode));
      }
    }
  }

  dynamic _response(http.Response response, {bool? isBackgroundMode}) {
    JSON jsonData;
    try {
      jsonData = JSON.parse(response.body);
      debugPrint('API log Response: ${jsonData.rawString()}');
    } catch (error) {
      debugPrint('API log Response: ${response.body.toString()}');
      debugPrint('API log error: ${error.toString()}');

      if (response.body.toString().startsWith('<html>') ||
          response.body.toString().startsWith('<!doctype html5>')) {
        return JSON(errorResponse(response.body.toString(), 999));
      }

      return JSON(errorResponse(
          'Yêu cầu không hợp lệ! Vui lòng liên hệ Quản trị viên để được hỗ trợ!${'Status code: 999'}',
          999));
    }

    switch (response.statusCode) {
      case 200:
        return jsonData;
      case 400:
        return jsonData;
      case 401:
        handle401();
        break;
      case 403:
        handle403();
        break;
      case 500:
        handle500();
        break;
      default:
        return JSON(errorResponse(
            'Yêu cầu không hợp lệ! Vui lòng liên hệ Quản trị viên để được hỗ trợ!${'Status code: ${response.statusCode}'}',
            response.statusCode));
    }
  }

  Future handle401() async {
    await showDialogError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại!',
        action: () {
      Get.offAllNamed(Routes.loginScreen);
    });
  }

  Future handle403() async {
    await showDialogError('Bạn không có quyền sử dụng chức năng này!',
        action: () {
      Get.back();
    });
  }

  Future handle500() async {
    await showDialogError('Lỗi hệ thống vui lòng chuyển sang Alo1', action: () {
      launchUrl(Uri.parse(uriLink.toString()),
          mode: LaunchMode.externalApplication);
    });
  }
}
