import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:face/page/login_page.dart';
import 'package:face/util/router.dart';
import 'package:face/util/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 网络通讯
class Http {
  //配置dio，通过BaseOptions
  static final Http instance = Http._internal();
  final BaseOptions options = BaseOptions(
      baseUrl: "http://emiya-sakura.natapp1.cc/api",
      connectTimeout: 5000,
      receiveTimeout: 5000);
  late Dio dio;

  // 单例模式使用Http类，
  factory Http() => instance;

  Http._internal() {
    dio = Dio(options);

    // 添加拦截器
    dio.interceptors.add(AppInterceptors());
  }

  //dio的GET请求
  get(url) {
    return dio.get(url).then((res) => json.decode(res.toString()));
  }

  //dio的POST请求
  post(url, data) {
    return dio
        .post(url, data: json.encode(data))
        .then((res) => json.decode(res.toString()));
  }
}

class AppInterceptors extends Interceptor {
  @override
  dynamic onRequest(options, handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    options.headers = {'authorization': token};
    return super.onRequest(options, handler);
  }

  @override
  dynamic onError(err, handler) async {
    err.error = AppException.create(err);
    Toaster().show(err.error.toString());
    return super.onError(err, handler);
  }

  @override
  dynamic onResponse(response, handler) {
    return super.onResponse(response, handler);
  }
}

/// 自定义异常
class AppException implements Exception {
  final String message;

  AppException(
    this.message,
  );

  @override
  String toString() {
    return message;
  }

  factory AppException.create(DioError err) {
    switch (err.type) {
      case DioErrorType.cancel:
        return BadRequestException("请求取消");
      case DioErrorType.connectTimeout:
        return BadRequestException("连接超时");
      case DioErrorType.sendTimeout:
        return BadRequestException("请求超时");
      case DioErrorType.receiveTimeout:
        return BadRequestException("响应超时");
      case DioErrorType.response:
        try {
          int? errCode = err.response!.statusCode;
          switch (errCode) {
            case 400:
              return BadRequestException("请求语法错误");
            case 401:
              NavRouter.push(LoginPage.tag);
              return UnauthorisedException("登录信息已失效");
            case 402:
              return UnauthorisedException("权限不足");
            case 403:
              return UnauthorisedException("服务器拒绝执行");
            case 404:
              return UnauthorisedException("无法连接服务器");
            case 405:
              return UnauthorisedException("请求方法被禁止");
            case 500:
              return UnauthorisedException("服务器内部错误");
            case 502:
              return UnauthorisedException("无效的请求");
            case 503:
              return UnauthorisedException("服务器失效");
            case 505:
              return UnauthorisedException("不支持的HTTP协议请求");
            default:
              return AppException(err.response!.statusMessage!);
          }
        } on Exception catch (_) {
          return AppException("未知错误");
        }
      case DioErrorType.other:
        if (err.error is SocketException) {
          return AppException(' 似乎与网络失去了连接');
        } else {
          return AppException("未知错误");
        }
      default:
        return AppException(err.error.message);
    }
  }
}

/// 请求错误
class BadRequestException extends AppException {
  BadRequestException(String message) : super(message);
}

/// 未认证异常
class UnauthorisedException extends AppException {
  UnauthorisedException(String message) : super(message);
}
