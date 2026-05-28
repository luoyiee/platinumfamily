import 'dart:convert';
import 'package:earlybird/src/manager/js_bridge_manager.dart';

import '../constants/bridge_constants.dart';

/// 跨平台日志工具
/// iOS 原生接收字典格式，Android 原生接收字符串格式
class LogUtils {
  
  /// 打印日志到原生端
  /// [level] 日志级别：debug, info, warn, error
  /// [msg] 日志消息
  /// [tag] 标签,加上 flutter 标志
  /// [data] 额外数据（可选）
  static void _log(String level, String tag, String msg, {Object? data}) {
    try {
      // 构建日志对象
      final logData = _buildLogData(level, "flutter_$tag", msg, data: data);

      // 调用原生端日志处理
      _callWebViewLog(logData);
    } catch (e) {
      // 如果桥接失败，至少要在控制台打印
      print('Logger error: $e');
      _printToConsole('error', 'Logger failed: $e');
    }
  }
  
  /// 构建日志数据
  static Map<String, dynamic> _buildLogData(String level, String? tag, String msg, {Object? data}) {
    return {
      'level': level,
      'tag': tag,
      'message': msg,
      'data': data,
    };
  }
  
  /// 通过 WebView 桥接调用原生端日志
  static void _callWebViewLog(Map<String, dynamic> logData) {
    try {
      _callDirectly(logData);
    } catch (e) {
      print('WebView log call failed: $e');
    }
  }
  
  /// 直接调用桥接
  static void _callDirectly(Map<String, dynamic> logData) {
    // 为 iOS 构建字典：包含 funName 和 status（很多 iOS 端是这样取值的）
    final envelope = {
      'funName': BridgeConstants.callWriteLog,
      'status': jsonEncode(logData),
    };
    JsBridgeManager.log(envelope);
  }
  
  /// 在控制台打印日志
 static  void _printToConsole(String level, String message, {Object? data, String? tag}) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag] ' : '';
    final dataStr = data != null ? ' | Data: $data' : '';
    
    final logMessage = '$tagStr[$level] $message$dataStr ($timestamp)';
    
    switch (level.toLowerCase()) {
      case 'error':
        print('❌ $logMessage');
        break;
      case 'warn':
        print('⚠️ $logMessage');
        break;
      case 'info':
        print('ℹ️ $logMessage');
        break;
      case 'debug':
        print('🐛 $logMessage');
        break;
      default:
        print('📝 $logMessage');
    }
  }

  /// 外部调用
  static void d(String tag, String msg, {Object? data}) {
    _log('debug', tag, msg, data: data);
  }
  
  static void i(String tag, String msg, {Object? data}) {
    _log('info', tag, msg, data: data);
  }

  static void w(String tag, String msg, {Object? data}) {
    _log('warn', tag, msg, data: data);
  }

  static void e(String tag, String msg, {Object? data}) {
    _log('error', tag, msg, data: data);
  }
}

