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
import 'package:http_parser/http_parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:g_json/g_json.dart';
import 'package:http/http.dart' as http;

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

  Map errorResponse(String message, int code) {
    return ServerResponse(message: message, statusCode: code).toJson();
  }

  Future<JSON> get(String url,
      {required Map<String, dynamic> params,
      bool isRequireAuth = false,
      bool backgroundMode = false}) async {
    try {
      if (isRequireAuth) {
        final token = AuthenticationKey.shared.token;
        header.addAll({HttpHeaders.authorizationHeader: 'Bearer $token'});
      }
      if (!backgroundMode) {
        ProgressHUD.show();
      }
      final queryString = Uri(queryParameters: params).query;
      final response = await http
          .get(
            Uri.parse('${Environment.getServerUrl()}$url${'?$queryString'}'),
            headers: header,
          )
          .timeout(const Duration(seconds: _timeOut));
      debugPrint('API log code: ${response.statusCode}');
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
        return JSON(errorResponse(
            e.toString() ?? 'Đã có lỗi xảy ra. Xin thử lại sau!', commonCode));
      }
    }
  }

  Future<JSON> post(String url, Map<String, dynamic> params,
      {bool isRequireAuth = false, bool backgroundMode = false}) async {
    if (isRequireAuth) {
      final token = AuthenticationKey.shared.token;
      header.addAll({HttpHeaders.authorizationHeader: 'Bearer $token'});
    }
    try {
      if (!backgroundMode) {
        ProgressHUD.show();
      }
      final body = jsonEncode(params);
      final response = await http
          .post(Uri.parse(Environment.getServerUrl() + url),
              body: body, headers: header)
          .timeout(const Duration(seconds: _timeOut));
      final responseJson =
          _response(response, isBackgroundMode: backgroundMode);
      return responseJson;
    } catch (e) {
      ProgressHUD.dismiss();
      if (e is SocketException) {
        return JSON(errorResponse(AppStrings.noInternet, codeNoInternet));
      }
      if (e is TimeoutException) {
        return JSON(errorResponse(AppStrings.timeOutError, codeTimeOut));
      } else {
        return JSON(errorResponse(
            e.toString() ?? 'Đã có lỗi xảy ra. Xin thử lại sau!', commonCode));
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
        return JSON(errorResponse(
            e.toString() ?? 'Đã có lỗi xảy ra. Xin thử lại sau!', commonCode));
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
        return JSON(errorResponse(
            e.toString() ?? 'Đã có lỗi xảy ra. Xin thử lại sau!', commonCode));
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
            e.toString() ?? 'Đã có lỗi xảy ra. Xin thử lại sau!', commonCode));
      }
    }
  }

  dynamic _response(http.Response response, {bool? isBackgroundMode}) {
    JSON jsonData;
    if (!(isBackgroundMode ?? false)) {
      ProgressHUD.dismiss();
    }
    if (response.body == null) {
      return JSON(errorResponse(
          'Yêu cầu không hợp lệ! Vui lòng liên hệ Quản trị viên để được hỗ trợ!${'Status code: ${response.statusCode}'}',
          response.statusCode));
    }

    try {
      jsonData = JSON.parse(response.body);
      final error = jsonData.rawString();
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
        throw 'Lỗi hệ thống. Vui lòng liên hệ Quản trị viên để được hỗ trợ!';
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
}
