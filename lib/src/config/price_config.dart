/// TalkiePods 价格配置管理类
///
/// 支持四种促销类型：
/// A. 非会员 & 未注册用户 & 已是 Platinum Family 有效期会员｜已取消自动续订
/// B. 现有 JusTalk/Kids Premium 会员｜升级现有会员至Platinum Family
/// C. 现有 Premium Family 会员｜升级现有会员至Platinum Family
/// D. 已是 Platinum Family 有效期会员｜未取消自动续订｜仅加购耳机

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sprintf/sprintf.dart';
import '../../main.dart' show loc;

/// 促销类型枚举
enum PromoType {
  /// 阶梯定价
  tieredPricing,
  /// 固定折扣
  fixedDiscount,
}

/// 用户会员类型枚举
enum UserType {
  /// 模式 A. 非会员 或 未注册用户
  planOthers,
  /// 模式 B/C. Premium 会员 或 Premium Family 会员
  planPremiumOrFamily,
  /// 模式 D. Platinum Family 会员 （仅加购耳机）
  planPlatinumFamily,
}

/// TalkiePods 单项价格信息
class TalkiePodsPrice {
  /// 数量
  final int quantity;
  /// 最终价格
  final String finalPrice;
  /// 原价
  final String originalPrice;
  /// 优惠券 ID
  final String couponId;
  /// 下一个促销数量（可选）
  final int? promoNextQty;
  /// 下一个促销价格（可选）
  final String? promoNextPrice;
  /// 耳机 + 会员销售价（可选）
  final String? talkiePodsMemberSalePrice;
  /// 耳机 + 会员划线价（可选）
  final String? talkiePodsMemberOriginalPrice;

  const TalkiePodsPrice({
    required this.quantity,
    required this.finalPrice,
    required this.originalPrice,
    required this.couponId,
    this.promoNextQty,
    this.promoNextPrice,
    this.talkiePodsMemberSalePrice,
    this.talkiePodsMemberOriginalPrice,
  });

  /// 从 JSON 创建对象
  factory TalkiePodsPrice.fromJson(Map<String, dynamic> json) {
    return TalkiePodsPrice(
      quantity: json['quantity'] as int,
      finalPrice: json['finalPrice'],
      originalPrice: json['originalPrice'],
      couponId: json['couponId'] as String,
      promoNextQty: json['promoNextQty'] as int?,
      promoNextPrice: json['promoNextPrice'] as String?,
      talkiePodsMemberSalePrice: json['talkiePodsMemberSalePrice'] as String?,
      talkiePodsMemberOriginalPrice: json['talkiePodsMemberOriginalPrice'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    final map = {
      'quantity': quantity,
      'finalPrice': finalPrice,
      'originalPrice': originalPrice,
      'couponId': couponId,
    };
    if (promoNextQty != null) {
      map['promoNextQty'] = promoNextQty!;
    }
    if (promoNextPrice != null) {
      map['promoNextPrice'] = promoNextPrice!;
    }
    if (talkiePodsMemberSalePrice != null) {
      map['talkiePodsMemberSalePrice'] = talkiePodsMemberSalePrice!;
    }
    if (talkiePodsMemberOriginalPrice != null) {
      map['talkiePodsMemberOriginalPrice'] = talkiePodsMemberOriginalPrice!;
    }
    return map;
  }

}

/// 价格配置数据
class PriceConfiguration {
  /// 促销类型
  final PromoType promoType;
  /// 一年 platinum 会员价格（可选，planPlatinumFamily 不需要）
  final String? onePlatinumPrice;
  /// 介绍页销售价格
  final String introPrice;
  /// 介绍页划线价
  final String introOriginalPrice;
  /// TalkiePods 价格列表
  final List<TalkiePodsPrice> talkiePods;

  const PriceConfiguration({
    required this.promoType,
    this.onePlatinumPrice,
    required this.introPrice,
    required this.introOriginalPrice,
    required this.talkiePods,
  });

  /// 从 JSON 创建对象
  factory PriceConfiguration.fromJson(Map<String, dynamic> json) {
    final promoTypeStr = json['promoType'] as String;
    final promoType = promoTypeStr == 'tieredPricing'
        ? PromoType.tieredPricing
        : PromoType.fixedDiscount;

    final talkiePodsJson = json['talkiePods'] as List<dynamic>;
    final talkiePods = talkiePodsJson
        .map((item) => TalkiePodsPrice.fromJson(item as Map<String, dynamic>))
        .toList();

    return PriceConfiguration(
      promoType: promoType,
      introPrice: json['introPrice'],
      onePlatinumPrice: json['onePlatinumPrice'],
      introOriginalPrice: json['introOriginalPrice'],
      talkiePods: talkiePods,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'promoType': promoType == PromoType.tieredPricing ? 'tieredPricing' : 'fixedDiscount',
      'introPrice': introPrice,
      'onePlatinumPrice': onePlatinumPrice,
      'introOriginalPrice': introOriginalPrice,
      'talkiePods': talkiePods.map((item) => item.toJson()).toList(),
    };
  }

  /// 根据数量获取价格信息
  TalkiePodsPrice? getPriceByQuantity(int quantity) {
    try {
      return talkiePods.firstWhere((item) => item.quantity == quantity);
    } catch (e) {
      return null;
    }
  }
}

/// TalkiePods 价格配置管理器
class PriceConfigManager {
  PriceConfigManager._();

  /// 单例实例
  static final PriceConfigManager instance = PriceConfigManager._();

  /// 价格配置缓存
  Map<UserType, PriceConfiguration>? _priceConfigs;

  /// 配置文件路径
  static const String _configPath = 'assets/config/price_config.json';

  /// 从 JSON 文件加载价格配置
  Future<void> loadConfig() async {
    try {
      // 读取 JSON 文件
      final String jsonString = await rootBundle.loadString(_configPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 解析配置
      _priceConfigs = {
        UserType.planOthers: PriceConfiguration.fromJson(
          jsonData['planOthers'] as Map<String, dynamic>,
        ),
        UserType.planPremiumOrFamily: PriceConfiguration.fromJson(
          jsonData['planPremiumOrFamily'] as Map<String, dynamic>,
        ),
        UserType.planPlatinumFamily: PriceConfiguration.fromJson(
          jsonData['planPlatinumFamily'] as Map<String, dynamic>,
        ),
      };
    } catch (e) {
      print('Error loading price config: $e');
      // 如果加载失败，使用空配置
      _priceConfigs = {};
    }
  }

  /// 根据用户类型和数量获取具体价格信息（同步方法，需要先调用 loadConfig）
  TalkiePodsPrice? getPriceByUserTypeAndQuantity(UserType userType, int quantity) {
    final config = getConfigByUserTypeSync(userType);
    return config?.getPriceByQuantity(quantity);
  }

  /// 获取所有支持的数量选项（根据用户类型和黑五模式）（同步方法，需要先调用 loadConfig）
  ///
  /// [userType] 用户类型
  /// [isBlackFriday] 是否为黑五模式，默认为 false
  /// - true: 最多支持 5 个耳机
  /// - false: 最多支持 3 个耳机
  List<int> getAvailableQuantities(UserType userType, {bool isBlackFriday = false}) {
    final config = getConfigByUserTypeSync(userType);
    final allQuantities = config?.talkiePods.map((item) => item.quantity).toList() ?? [];

    // 根据黑五模式限制最大数量
    final maxQuantity = isBlackFriday ? 5 : 3;
    return allQuantities.where((quantity) => quantity <= maxQuantity).toList();
  }

  /// 获取促销类型（同步方法，需要先调用 loadConfig）
  PromoType? getPromoType(UserType userType) {
    final config = getConfigByUserTypeSync(userType);
    return config?.promoType;
  }

  /// 获取促销提示信息（同步方法，需要先调用 loadConfig）
  ///
  /// [userType] 用户类型
  /// [currentQty] 当前选择的耳机数量
  /// [isBlackFriday] 是否为黑五模式，默认为 false
  ///
  /// 返回值：
  /// - 如果可以显示促销提示，返回提示文案字符串
  /// - 如果不应该显示促销提示，返回 null
  ///
  /// 显示逻辑：
  /// - planOthers（模式A）：无论是否选择，都会显示促销提示
  ///   - currentQty = 0：显示特殊的零数量提示（promoTipZero）
  ///   - currentQty > 0：显示对应数量的促销提示
  /// - planPremiumOrFamily（模式B/C）：只有选择了耳机才显示促销提示
  /// - planPlatinumFamily（模式D）：不显示促销提示
  ///
  /// 不显示的情况：
  /// - 用户类型为 planPlatinumFamily（模式D）
  /// - 当前数量的配置中没有 promoNextQty 或 promoNextPrice
  /// - 非黑五模式下，当前数量已达到可用的最大值
  String? getPromoTip({
    required UserType userType,
    required int currentQty,
    bool isBlackFriday = false,
  }) {
    // 模式 D 不显示促销提示
    if (userType == UserType.planPlatinumFamily) {
      return null;
    }

    final config = getConfigByUserTypeSync(userType);
    if (config == null) {
      return null;
    }

    if (currentQty == 0 && userType == UserType.planOthers) {
      return loc.promoTipZero;
    }

    // 获取当前数量的价格配置
    final currentPrice = config.getPriceByQuantity(currentQty);
    if (currentPrice == null) {
      return null;
    }

    // 检查是否有下一个促销信息
    if (currentPrice.promoNextQty == null || currentPrice.promoNextPrice == null) {
      return null;
    }
    // 非黑五模式下，获取可用数量列表，检查是否已达最大值
    if (!isBlackFriday) {
      final maxQty = 3;
      final allQty = config.talkiePods.map((item) => item.quantity).toList();
      final availableQuantities = allQty.where((quantity) => quantity <= maxQty).toList();
      if (availableQuantities.isNotEmpty && currentQty == availableQuantities.last) {
        return null;
      }
    }
    final nextPrice = currentPrice.promoNextPrice!;
    return getPromoStr(currentQty, nextPrice);
  }

  String? getPromoStr(int currentQty, String nextPrice) {
    if (currentQty == 1) {
      return sprintf(loc.promoTipOneFormat, [nextPrice]);
    }
    else if (currentQty == 2) {
      return sprintf(loc.promoTipTwoFormat, [nextPrice]);
    }
    else if (currentQty == 3) {
      return sprintf(loc.promoTipThreeFormat, [nextPrice]);
    }
    else if (currentQty == 4) {
      return sprintf(loc.promoTipFourFormat, [nextPrice]);
    }
    return null;
  }

  /// 同步方法：根据用户类型获取价格配置（需要先调用 loadConfig）
  PriceConfiguration? getConfigByUserTypeSync(UserType userType) {
    if (_priceConfigs == null) {
      throw StateError('Price config not loaded. Call loadConfig() first.');
    }
    return _priceConfigs?[userType];
  }

  /// 同步方法：获取价格配置的 JSON 格式（需要先调用 loadConfig）
  Map<String, dynamic>? getConfigJsonSync(UserType userType) {
    return getConfigByUserTypeSync(userType)?.toJson();
  }

  /// 获取 platinum 价格（带默认值）
  /// 所有用户类型的 platinum 价格都一样，从任意配置中获取即可
  String getPlatinumPrice({String defaultPrice = '\$109.99'}) {
    if (_priceConfigs == null || _priceConfigs!.isEmpty) {
      return defaultPrice;
    }
    // 找到第一个有 onePlatinumPrice 的配置
    for (var config in _priceConfigs!.values) {
      if (config.onePlatinumPrice != null) {
        return config.onePlatinumPrice!;
      }
    }
    return defaultPrice;
  }

  /// 获取介绍页价格（带默认值）
  String getIntroPrice(UserType userType, {String defaultPrice = '\$129.99'}) {
      final config = getConfigByUserTypeSync(userType);
      return config?.introPrice ?? defaultPrice;
  }

  /// 获取介绍页原价（带默认值）
  String getIntroOriginalPrice(UserType userType, {String defaultPrice = '\$149.99'}) {
      final config = getConfigByUserTypeSync(userType);
      return config?.introOriginalPrice ?? defaultPrice;
  }

  /// 获取耳机 + 会员销售总价（底部显示）
  ///
  /// [userType] 用户类型
  /// [quantity] 耳机数量，如果为 0，则返回 platinum 会员价格
  /// [defaultPrice] 默认价格
  String getTalkiePodsMemberSalePrice(UserType userType, int quantity, {String defaultPrice = '\$129.99'}) {
    // 如果数量为 0，返回 platinum 会员价格
    if (quantity == 0) {
      return getPlatinumPrice(defaultPrice: defaultPrice);
    }

    final config = getConfigByUserTypeSync(userType);
    final priceInfo = config?.getPriceByQuantity(quantity);

    // planPlatinumFamily 类型取 finalPrice
    if (userType == UserType.planPlatinumFamily) {
      return priceInfo?.finalPrice ?? defaultPrice;
    }

    return priceInfo?.talkiePodsMemberSalePrice ?? defaultPrice;
  }

  /// 获取耳机 + 会员销售原价（底部显示）
  ///
  /// [userType] 用户类型
  /// [quantity] 耳机数量，如果为 0，则返回 platinum 会员价格
  /// [defaultPrice] 默认价格
  String getTalkiePodsMemberOriginalPrice(UserType userType, int quantity, {String defaultPrice = '\$149.99'}) {
    // 如果数量为 0，返回 platinum 会员价格
    if (quantity == 0) {
      return getPlatinumPrice(defaultPrice: defaultPrice);
    }

    final config = getConfigByUserTypeSync(userType);
    final priceInfo = config?.getPriceByQuantity(quantity);

    // planPlatinumFamily 类型取 originalPrice
    if (userType == UserType.planPlatinumFamily) {
      return priceInfo?.originalPrice ?? defaultPrice;
    }

    return priceInfo?.talkiePodsMemberOriginalPrice ?? defaultPrice;
  }

  /// 获取用户会员类型
  /// 优先级 planPlatinumFamily > planPremiumOrFamily > planOthers
  UserType getAppUserType(String vipType) {
    if (vipType == "platinumFamily") {  // platinum family 会员
      return UserType.planPlatinumFamily;
    } else if (vipType == "premium") {  // premium family 会员 或 premium 会员
      return UserType.planPremiumOrFamily;
    } else {  // 无会员
      return UserType.planOthers;
    }
  }

}
