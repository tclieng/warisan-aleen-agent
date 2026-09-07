/// Warisan Aleen 后端 API 客户端。
/// 对应 FastAPI 路由（app/main.py）。
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient extends ChangeNotifier {
  // Android 模拟器访问宿主机用 10.0.2.2；真机用电脑局域网 IP。
  String baseUrl;
  ApiClient({this.baseUrl = 'http://10.0.2.2:8000'});

  /// 重新连接尝试次数
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(milliseconds: 800);
  static const Duration _timeout = Duration(seconds: 8);

  /// 最后一次错误（UI 可读）
  String? lastError;

  void setBaseUrl(String url) {
    baseUrl = url.trim();
    notifyListeners();
  }

  Map<String, String> get _h => {'Content-Type': 'application/json'};

  Future<dynamic> _request(
    Future<http.Response> Function() send, {
    String label = 'request',
  }) async {
    Object? lastErr;
    for (var i = 0; i <= _maxRetries; i++) {
      try {
        final res = await send().timeout(_timeout);
        if (res.statusCode >= 400) {
          throw Exception('${res.statusCode}: ${res.body}');
        }
        lastError = null;
        return jsonDecode(res.body);
      } catch (e) {
        lastErr = e;
        if (i < _maxRetries) {
          await Future.delayed(_retryDelay);
        }
      }
    }
    lastError = '$label: $lastErr';
    if (kDebugMode) debugPrint(lastError);
    throw Exception(lastError);
  }

  Future<dynamic> _post(String path,
      [Map<String, dynamic>? body]) async {
    return _request(
      () => http.post(Uri.parse('$baseUrl$path'),
          headers: _h, body: body == null ? null : jsonEncode(body)),
      label: 'POST $path',
    );
  }

  Future<dynamic> _get(String path) async => _request(
        () => http.get(Uri.parse('$baseUrl$path')),
        label: 'GET $path',
      );

  /// 简单的健康检查
  Future<bool> ping() async {
    try {
      await _get('/');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> status() async =>
      Map<String, dynamic>.from(await _get('/status'));

  Future<Map<String, dynamic>> generate(String topic, String platform) async =>
      Map<String, dynamic>.from(
          await _post('/generate', {'topic': topic, 'platform': platform}));

  Future<dynamic> publish(int id) async =>
      await _post('/posts/$id/publish');

  Future<List<dynamic>> posts() async =>
      List<dynamic>.from(await _get('/posts'));

  Future<dynamic> schedule(int id, String iso) async =>
      await _post('/posts/$id/schedule', {'scheduled_at': iso});

  Future<dynamic> setToken(String token) async =>
      await _post('/settings/token', {'token': token});

  Future<dynamic> setDryRun(bool v) async =>
      await _post('/settings/dryrun', {'dry_run': v});

  Future<dynamic> publishDue() async => await _post('/publish/due');
}
