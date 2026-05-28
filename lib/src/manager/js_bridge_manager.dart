import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import '../../main.dart';
import '../constants/bridge_constants.dart';
import '../utils/js_utils.dart';
import 'dart:convert';

extension type WebViewJavascriptBridgeBinding._(JSObject _) implements JSObject {
  external void callHandler(JSAny? handlerName, JSAny? data, [JSFunction? callback]);
  external void registerHandler(JSAny? handlerName, JSFunction handler);
}

@JS('setupWebViewJavascriptBridge')
external void _setupWebViewJavascriptBridge(JSFunction callback);

@JS('initVConsole')
external void _initVConsoleJs(JSBoolean isTestMode);

@JS('WebViewJavascriptBridge')
external WebViewJavascriptBridgeBinding get webViewJavascriptBridge;

class JsBridgeManager {
  static bool _isBridgeReady = false;
  static void Function()? _onReady;

  static void initVConsole(bool isTestMode) => _initVConsoleJs(isTestMode.toJS);

  static void setup(void Function() onReady) {
    _onReady = onReady;
    _setupWebViewJavascriptBridge(_onBridgeReady.toJS);
  }

  static void _onBridgeReady(JSAny? _) {
    _isBridgeReady = true;
    _onReady?.call();
  }

  static void _callHandler(String handlerName, [Object? data, void Function(JSAny?)? callback]) {
    if (isWebDesignMode || !_isBridgeReady) {
      debugPrint('callHandler skipped (bridge not ready): $handlerName');
      return;
    }
    try {
      consoleLog('callHandler: $handlerName, data: $data');
      webViewJavascriptBridge.callHandler(handlerName.toJS, data?.jsify(), callback?.toJS);
    } catch (e) {
      debugPrint('callHandler error: $handlerName, error: $e');
    }
  }

  static void _registerHandler(String handlerName, void Function(JSAny?) handler) {
    if (isWebDesignMode || !_isBridgeReady) {
      debugPrint('registerHandler skipped (bridge not ready): $handlerName');
      return;
    }
    try {
      consoleLog('registerHandler: $handlerName');
      webViewJavascriptBridge.registerHandler(handlerName.toJS, handler.toJS);
    } catch (e) {
      debugPrint('registerHandler error: $handlerName, error: $e');
    }
  }

  static void finishWeb() {
    _callHandler(BridgeConstants.callFinishWeb);
  }

  static void loadingSuccess() {
    _callHandler(BridgeConstants.callLoadingSuccess);
  }

  static void initWeb({required Function(String?) callback}) {
    _callHandler(BridgeConstants.callInitWeb, null, (JSAny? responseData) {
      callback(jsAnyToString(responseData));
    });
  }

  static void log(Object envelope) {
    final data = isIos ? envelope : jsonEncode(envelope);
    _callHandler(BridgeConstants.callWriteLog, data);
  }

  static void aliTrack(Map<String, dynamic> paramsJson) {
    _callHandler(BridgeConstants.callJsToApp, paramsJson.jsify());
  }

  /// 查询用户能享受多少天免费试用及当前用户会员类型
  static void freeTrialDay({required Function(Map?) callback}) {
    _callHandler(BridgeConstants.callJsToApp, {'action': BridgeConstants.actionFreeTrialDay}, (JSAny? responseData) {
      consoleLog('freeTrialDay responseData: $responseData');
      callback(jsAnyToMap(responseData));
    });
  }

  /// 通知原生打开新网页
  static void startNewH5ForResult(String url) {
    _callHandler(BridgeConstants.callJsToApp, {'action': BridgeConstants.actionStartNewH5ForResult, 'url': url});
  }

  /// 上报新网页成功结果给原生
  static void setNewH5Result(String productId, String sessionId, bool vipUser) {
    _callHandler(BridgeConstants.callJsToApp, {
      'action': BridgeConstants.registerSetNewH5Result,
      'result': jsonEncode({'productId': productId, 'sessionId': sessionId, 'vipUser': vipUser}),
    });
  }

  static void queryNewH5Result({required Function(Map) callback}) {
    _registerHandler(BridgeConstants.registerSetNewH5Result, (JSAny? responseData) {
      consoleLog('queryNewH5Result responseData: $responseData');
      final Map? responseMap = jsAnyToMap(responseData);
      if (responseMap != null) callback(responseMap);
    });
  }

  /// 注册返回事件监听
  static void registerBackPressedListener({Function()? onBackPressed}) {
    _registerHandler(BridgeConstants.registerOnNativeBack, (JSAny? responseData) {
      consoleLog('onNativeBack  $responseData');
      final shouldIntercept = _handleBackPressed(onBackPressed);
      _callHandler(BridgeConstants.callNotifyNativeBackResult, shouldIntercept.toString());
    });
  }

  static bool _handleBackPressed(Function()? onBackPressed) {
    if (onBackPressed != null) {
      onBackPressed();
      return true;
    }
    finishWeb();
    return true;
  }

  /// 设置返回键拦截（默认禁用）
  static void setBackPressInterception({bool enabled = false}) {
    _callHandler(BridgeConstants.callJsToApp, {
      'action': BridgeConstants.actionSetBackPressMode,
      'mode': enabled ? 'intercept' : 'default',
    });
  }

}
