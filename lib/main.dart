import 'dart:convert';
import 'package:earlybird/src/config/price_config.dart';
import 'package:earlybird/src/constants/tracker_constants.dart';
import 'package:earlybird/src/constants/url_constants.dart';
import 'package:earlybird/src/manager/js_bridge_manager.dart';
import 'package:earlybird/src/manager/tracker_manager.dart';
import 'package:earlybird/src/manager/user_type_manager.dart';
import 'package:earlybird/src/pages/membership_claim_page.dart';
import 'package:earlybird/src/pages/pre_register/pre_empty_page.dart';
import 'package:earlybird/src/pages/talkiepods/talkiepods_membership_activation_page.dart';
import 'package:earlybird/src/product/product_string.dart';
import 'package:earlybird/src/routes/app_routes.dart';
import 'package:earlybird/src/utils/common_utils.dart';
import 'package:earlybird/src/utils/nav_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';
import 'dart:js_interop';
import 'src/utils/js_utils.dart';

import 'src/config/app_config.dart';
import 'src/manager/dialog_manager.dart';
import 'res/string_library.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/pages/talkiepods/talkiepods_home_page.dart';
import 'src/pages/talkiepods/talkiepods_select_page.dart';
import 'src/utils/time_utils.dart';
import 'package:web/web.dart' as web;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      builder: EasyLoading.init(),
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('hi'),
        Locale('id'),
        Locale('it'),
        Locale('ja'),
        Locale('ko'),
        Locale('nl'),
        Locale('pt'),
        Locale('ru'),
        Locale('tr'),
        Locale('vi'),
        Locale('zh'), // 简体中文
        Locale('zh', 'TW'), // 繁体中文
      ],
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;
        final sessionId = args?['sessionId'] as String? ?? _sessionId;
        final productId = args?['productId'] as String? ?? _productId;
        final platinumFamilyOwnerDue = args?['platinumFamilyOwnerDue'] as int? ?? 0;
        final payResult = args?['result'] as bool? ?? false;
        final vipUser = args?['vipUser'] as bool? ?? _vipUser;
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const InitialPage());
          case AppRoutes.home:
          case AppRoutes.preSignupHome:
            return MaterialPageRoute(builder: (context) => const TalkiePodsHomePage());
          case AppRoutes.productDetail:
          case AppRoutes.preSignupProductDetail:
            return MaterialPageRoute(builder: (context) => const TalkiePodsSelectPage());
          case AppRoutes.membershipClaim: // 会员领取页
            return MaterialPageRoute(builder: (context) => const MembershipClaimPage());
          case AppRoutes.preSignupEmpty:  // 预注册成功页
            return MaterialPageRoute(builder: (context) => PreEmptyPage(sessionId: sessionId, productId: productId));
          case AppRoutes.talkiePodsMembershipActivation:
            return MaterialPageRoute(builder: (context) => TalkiePodsMembershipActivationPage(sessionId: sessionId, productId: productId,
                platinumFamilyOwnerDue: platinumFamilyOwnerDue, result: payResult, vipUser: vipUser));
          case AppRoutes.payResultEmpty:
            if (productId != null && sessionId != null) {
              if (CommonUtil.unSupportNewJs()) {
                return MaterialPageRoute(builder: (context) => TalkiePodsMembershipActivationPage(sessionId: sessionId, productId: productId, vipUser: vipUser));
              } else {
                JsBridgeManager.setNewH5Result(productId, sessionId, vipUser);
              }
            }
          default:
            consoleLog('onGenerateRoute: 页面路由错误');
            throw FlutterError('onGenerateRoute 页面路由错误');
        }
        return null;
      },
      initialRoute: _initialRoute,
      navigatorObservers: [routeObserver, BackPressObserver()],
    );
  }
}

/// 初始空白页：用于应用初始化完毕后再决定跳转页面
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});
  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final String _tag = 'InitialPage';

  @override
  void initState() {
    super.initState();
    if (isWebDesignMode) {
      // 测试模式：加载价格配置后跳转到测试页面
      _loadPriceConfigAndNavigate();
      return;
    }
    // 等待桥接就绪后再调用，避免首次加载时桥尚未注入导致调用失败
    try {
      JsBridgeManager.setup(() {
        _initBackPressedListener();
        String currentHref = web.window.location.href;
        if (currentHref.contains('payResult=ok')) {
          final int firstQuestionIndex = currentHref.indexOf('?');
          if (firstQuestionIndex != -1) { // 将第一个 ? 之后的所有 ? 替换为 &
            final String beforeQuery = currentHref.substring(0, firstQuestionIndex + 1);
            final String afterQuery = currentHref.substring(firstQuestionIndex + 1).replaceAll('?', '&');
            currentHref = beforeQuery + afterQuery;
          }
          final uri = Uri.parse(currentHref);
          final queryParams = uri.queryParameters;
          String productId = queryParams['productId'] ?? "";
          String sessionId = queryParams['session_id'] ?? "";
          bool vipUser = queryParams['vipUser'] == 'true';
          // 解析 trackerMap 参数
          if (queryParams.containsKey('trackerMap')) {
            final String decodedTraceData = Uri.decodeComponent(queryParams['trackerMap']!);
            traceDataMap = jsonDecode(decodedTraceData);
          }
          // 解析 talkiesPods 耳机列表
          if (queryParams.containsKey('talkiesPods')) {
            final String decodedTalkiesPods = Uri.decodeComponent(queryParams['talkiesPods']!);
            talkiesPodsList = jsonDecode(decodedTalkiesPods);
          }
          AppConfig.traceId = traceDataMap['traceId'] ?? const Uuid().v4();
          TrackerManager.payResult(TrackerConstants.eventValuePayResultOk, productId);
          JsBridgeManager.setNewH5Result(productId, sessionId, vipUser);
        } else {
          JsBridgeManager.initWeb(callback: (String? responseString) {
            _initWebCallback(responseString);
          });
        }
      });
    } catch (e) {}
  }

  /// 加载价格配置及跳转到页面
  Future<void> _loadPriceConfigAndNavigate(
      {String route = AppRoutes.home}) async {
    if (redirectRoute.isEmpty && route != AppRoutes.membershipClaim) {
      try {
        await PriceConfigManager.instance.loadConfig();
        consoleLog('$_tag: Price config loaded successfully for userType: ${UserTypeManager().userType}');
      } catch (e) {
        consoleLog('$_tag: Failed to load price config: $e');
      }
    }
    if (mounted) {
      NavUtils.pushReplacementNamed(context, route);
    }
  }

  /// 跳转对应 Page
  void initPage() {
    consoleLog('$_tag: initPage path:${web.window.location.pathname}');
    String path = web.window.location.pathname ?? AppRoutes.home;
    path = AppRoutes.home;
    // 使用Uri来解析URL
    final uri = Uri.parse(web.window.location.href);
    // 从queryParameters中获取'action'的值
    consoleLog('$_tag: page: ${uri.queryParameters['page']}');
    if (uri.queryParameters['page'] != null) {
      path = '${uri.queryParameters['page']}';
    }
    consoleLog('$_tag: pushReplacementNamed: $path');
    _loadPriceConfigAndNavigate(route: path);
  }

  void redirectActiveMember() {
    _initialRoute = redirectRoute;
    consoleLog('$_tag: Redirect URL detected, $_initialRoute');
    // 修复 URL 中可能存在的多个 ? 符号问题
    String currentHref = web.window.location.href;
    final int firstQuestionIndex = currentHref.indexOf('?');
    if (firstQuestionIndex != -1) { // 将第一个 ? 之后的所有 ? 替换为 &
      final String beforeQuery = currentHref.substring(0, firstQuestionIndex + 1);
      final String afterQuery = currentHref.substring(firstQuestionIndex + 1).replaceAll('?', '&');
      currentHref = beforeQuery + afterQuery;
      consoleLog('$_tag: Fixed URL: $currentHref');
    }
    final uri = Uri.parse(currentHref);
    _productId = uri.queryParameters['productId'];
    _sessionId = uri.queryParameters['session_id'];
    _vipUser = uri.queryParameters['vipUser'] == 'true';
    consoleLog('$_tag: queryParameters:  ${uri.queryParameters}');
    NavUtils.pushReplacementNamed(context, redirectRoute);
    webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, jsonEncode({'action': 'clearHistory'}).toJS);
  }

  /// 处理来自 Android B 的版本响应，并根据版本号决定是否跳转或显示主内容。
  void _initWebCallback(String? responseString) {
    if (responseString == null) {
      return;
    }
    Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(responseString);
    } catch (e) {
      return;
    }
    final String? versionString = jsonMap['version'] as String?;
    if (versionString == null || (!versionString.startsWith("android.") && !versionString.startsWith("ios."))) {
      debugPrint("JSON 中没有 'version' 字段，或者其格式不符合预期。");
      return;
    }
    isIos = versionString.startsWith("ios.");
    isTestMode = jsonMap['isTestMode'] as bool? ?? false;
    // 初始化 vConsole（仅在测试模式下启用）
    JsBridgeManager.initVConsole(isTestMode);
    consoleLog('Build number: ${ProductConfig.versionCode}');
    consoleLog('_initWebCallback: $responseString');
    if (jsonMap.containsKey('traceData')) {
      traceDataMap = jsonMap['traceData'];
      AppConfig.traceId = traceDataMap['traceId'] ?? const Uuid().v4();
      consoleLog('traceData: ${jsonMap['traceData']}');
    } else {
      AppConfig.traceId = const Uuid().v4();
    }

    statusBarHeight = int.tryParse(jsonMap['statusBarHeight'] ?? '') ?? 0;
    topBarHeight = CommonUtil.pxToDp(context, int.tryParse(jsonMap['topBarHeight'] ?? '') ?? 0);
    safeBarTop = CommonUtil.pxToDp(context, int.tryParse(jsonMap['safeBarTop'] ?? '') ?? 0);
    safeBarBottom = CommonUtil.pxToDp(context, int.tryParse(jsonMap['safeBarBottom'] ?? '') ?? 0);

    _familyOwnerDue = int.tryParse(jsonMap['familyOwnerDue'] ?? '') ?? 0;
    int platinumFamilyOwnerDue = int.tryParse(jsonMap['platinumFamilyOwnerDue'] ?? '') ?? 0;
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    if (platinumFamilyOwnerDue > 0 && platinumFamilyOwnerDue > currentTimeMillis) {
      UserTypeManager().userType = UserType.planPlatinumFamily;
      titlePlatinumFamilyOwnerDue = sprintf(loc.titlePlatinumExpiresOnFormat, [formatTimestamp(platinumFamilyOwnerDue)]);
    }
    macAddress = (jsonMap['bluetoothMac'] as String?) ?? '';
    final isDarkValue = jsonMap['isDark'] as String? ?? '0';
    isDark = isDarkValue == "1";

    String versionCodeString = '';
    if (versionString.startsWith("android.")) {
      versionCodeString = versionString.substring("android.".length);
    } else {
      versionCodeString = versionString.substring("ios.".length);
    }
    versionCode = int.tryParse(versionCodeString);
    if (versionCode == null) {
      consoleLog('$_tag: Unable to parse version code $versionCodeString as a number.');
      return;
    }
    consoleLog('$_tag: versionCode: $versionCode');
    final String currentHref = web.window.location.href;
    bool needCheckUpdate = !currentHref.contains("page=") || currentHref.contains(AppRoutes.productDetail);
    if (needCheckUpdate && versionCode! < (isIos ? ProductConfig.iosMinVersion : ProductConfig.androidMinVersion)) {
      JsBridgeManager.loadingSuccess();
      DialogManager.showCommonDialog(
          context: context,
          titleStr: loc.updateDialogTitle,
          messageStr: loc.updateDialogMessage,
          confirmStr: loc.dialogUpdate,
          barrierDismissible: false,
          canPop: false,
          showCancelButton: true,
          onConfirm: () {
            if (isIos) {
              web.window.location.href = UrlConstants.updateUrl;
            } else {
              web.window.open(UrlConstants.updateUrl, "_blank");
            }
          },
          onCancel: () {
            JsBridgeManager.finishWeb();
          }
      );
      return;
    }

    consoleLog('$_tag: href: ${web.window.location.href}');

    final uri = Uri.parse(currentHref);
    final queryParams = uri.queryParameters;

    // 解析 trackerMap 参数
    if (queryParams.containsKey('trackerMap')) {
      final String decodedTraceData = Uri.decodeComponent(queryParams['trackerMap']!);
      consoleLog('MyApp: decodedTraceData: $decodedTraceData');
      traceDataMap = jsonDecode(decodedTraceData);
      consoleLog('MyApp: traceDataMap: $traceDataMap');
    }

    // 解析 talkiesPods 耳机列表
    if (queryParams.containsKey('talkiesPods')) {
      final String decodedTalkiesPods = Uri.decodeComponent(queryParams['talkiesPods']!);
      consoleLog('MyApp: talkiesPodsData: $decodedTalkiesPods');
      talkiesPodsList = jsonDecode(decodedTalkiesPods);
      consoleLog('MyApp: talkiesPodsList: $talkiesPodsList');
    }

    // 解析 productId 参数
    if (queryParams.containsKey('productId')) {
      _productId = queryParams['productId']!;
      consoleLog('MyApp: productId: $_productId');
    }

    if (!isWebDesignMode) {
      preRegisterMode = currentHref.contains('/preSignup-');
      if (currentHref.contains('payResult=ok')) {
        consoleLog('$_tag: payResult=ok');
        TrackerManager.payResult(TrackerConstants.eventValuePayResultOk, _productId);
      }
      if (currentHref.contains(AppRoutes.talkiePodsMembershipActivation)) {
        redirectRoute = AppRoutes.talkiePodsMembershipActivation;
      } else if (currentHref.contains(AppRoutes.preSignupEmpty)) {
        redirectRoute = AppRoutes.preSignupEmpty;
      } else if (currentHref.contains(AppRoutes.payResultEmpty)) {
        redirectRoute = AppRoutes.payResultEmpty;
      }
  }

    if (!currentHref.contains(AppRoutes.membershipClaim) && redirectRoute.isEmpty) {
      if (UserTypeManager().userType == UserType.planPlatinumFamily || currentHref.contains('vipType') || preRegisterMode) {
        UserTypeManager().markLoaded();
      } else {
        // 启动异步请求，数据返回后会自动通知所有监听页面更新
        JsBridgeManager.freeTrialDay(callback: (Map? responseMap) {
          if (responseMap == null) {
            UserTypeManager().markLoaded();
            return;
          }
          if (responseMap.containsKey('vipType')) {
            final newUserType = PriceConfigManager.instance.getAppUserType(responseMap['vipType'] ?? "");
            UserTypeManager().userType = newUserType;
            consoleLog('$_tag: freeTrialDay callback completed, userType: ${UserTypeManager().userType}');
          }
          UserTypeManager().markLoaded();
        });
        consoleLog('$_tag: freeTrialDay request sent, will update UI when data arrives');
      }
    }
    if (redirectRoute.isNotEmpty) {
      redirectActiveMember();
    } else {
      JsBridgeManager.loadingSuccess();
      initPage();
      if (!preRegisterMode) { // 预注册模式不需要查询历史订单
        checkPurchaseHistory();
      }
    }
  }

  void checkPurchaseHistory() {
    // 调用 js purchaseHistory 获取历史订单
    consoleLog('$_tag: purchaseHistory start');
    final Map<String, dynamic> purchaseParams = {
      'action': 'purchaseHistory',
      'platform': 'stripe',
    };

    final String paramsJson = jsonEncode(purchaseParams);
    webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.toJS, (JSAny? responseData) {
        if (responseData == null) {
          consoleLog('$_tag: purchaseHistory callback is null');
          return;
        }
        consoleLog('$_tag: purchaseHistory responseDataType: ${responseData.runtimeType}');
        consoleLog('$_tag: purchaseHistory callback $responseData');
        List<dynamic>? originalResponseList;
        try {
          originalResponseList = jsonDecode((responseData as JSString).toDart) as List<dynamic>;
          consoleLog('$_tag: Successfully decoded the originalResponse string into a list');
        } catch (e) {
          consoleLog('$_tag: Failed to decode originalResponse string: $e');
        }

        if (originalResponseList != null && originalResponseList.isNotEmpty) {
          // 遍历数组查找acknowledged为false的项
          for (int i = 0; i < originalResponseList.length; i++) {
            final Map<String, dynamic>? item = originalResponseList[i] as Map<String, dynamic>?;
            if (item != null && item.containsKey('acknowledged')) {
              final String acknowledged = item['acknowledged'] as String;
              if (acknowledged == 'false') {
                consoleLog('$_tag: Detect that acknowledged is false, stop checking');
                // 获取productId和sessionId
                final String? productId = item['productId'] as String?;
                final String? sessionId = item['sessionId'] as String?;
                if (productId != null && sessionId != null) {
                  consoleLog('$_tag: Extracted productId: $productId, Extracted sessionId: $sessionId');
                  _sessionId = sessionId;
                  _productId = productId;
                  NavUtils.pushReplacementNamed(context, AppRoutes.talkiePodsMembershipActivation, arguments: {
                    'sessionId': _sessionId,
                    'productId': _productId,
                  });
                  return;
                } else {
                  consoleLog('$_tag: The productId or sessionId is empty and cannot be redirected.');
                }
              }
            }
          }
        }
      }.toJS,
    );
  }

  void _initBackPressedListener() {
    // 注册返回键监听 - 一级页面点击返回关闭 WebView
    JsBridgeManager.registerBackPressedListener();
    // 返回键拦截由 BackPressObserver 根据栈深度自动控制
    JsBridgeManager.setBackPressInterception(enabled: true);
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context)!;
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}

  bool isFamilyMember() {
    return _familyOwnerDue > DateTime.now().millisecondsSinceEpoch;
  }

  bool isIos = false;
  bool isTestMode = false;
  bool preRegisterMode = false;
  String _initialRoute = '/';
  late AppLocalizations loc;
  String? _sessionId;
  String? _productId;
  bool _vipUser = false;
  String redirectRoute = "";
  int _familyOwnerDue = 0;
  bool isWebDesignMode = false;
  String macAddress = "";
  String titlePlatinumFamilyOwnerDue = "";
  Map<String, dynamic> traceDataMap = {'from': 'none'};

  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  bool blackFridayModeEnabled = false; // 黑五模式是否启用
  List<Map<String, dynamic>>? talkiesPodsList;
  int? versionCode;
  int statusBarHeight = 0; // dp
  int topBarHeight = 0; // px
  int safeBarTop = 0;  // px
  int safeBarBottom = 0;  // px
  bool isDark = false;

