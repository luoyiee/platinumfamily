import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:earlybird/main.dart' show blackFridayModeEnabled, loc, isWebDesignMode, titlePlatinumFamilyOwnerDue, isTestMode, macAddress, traceDataMap, isIos, preRegisterMode, talkiesPodsList, versionCode, safeBarTop, statusBarHeight, safeBarBottom;
import 'package:earlybird/res/color_style.dart';
import 'package:earlybird/src/config/price_config.dart';
import 'package:earlybird/src/utils/nav_utils.dart';
import 'package:earlybird/src/constants/url_constants.dart';
import 'package:earlybird/src/manager/user_type_manager.dart';
import 'package:earlybird/src/model/talkiepods_bean.dart';
import 'package:earlybird/src/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import '../../../res/image_library.dart';
import '../../../res/static_string_library.dart';
import '../../../res/string_library.dart';
import '../../../res/text_style.dart';
import '../../constants/constants.dart';
import '../../constants/tracker_constants.dart';
import '../../manager/dialog_manager.dart';
import '../../manager/js_bridge_manager.dart';
import '../../manager/tracker_manager.dart';
import '../../product/product_string.dart';
import '../../routes/app_routes.dart';
import '../../utils/common_utils.dart';
import '../../utils/js_utils.dart';
import '../../view/constraints_container.dart';
import '../../view/horizontal_gradient_text.dart';
import '../pre_register/pre_empty_page.dart';
import 'talkiepods_membership_activation_page.dart';

class TalkiePodsSelectPage extends StatefulWidget {
  const TalkiePodsSelectPage({super.key});

  @override
  State<TalkiePodsSelectPage> createState() => _TalkiePodsSelectPageState();
}

class _TalkiePodsSelectPageState extends State<TalkiePodsSelectPage> {
  final String _tag = "SelectionPage";
  int? _selectedIndex;
  // 存储每个 TalkiePod 的颜色选择，键为列表项的索引，值为一个 List<TestBean>
  final Map<int, List<TalkiePodsBean>> _selectedColors = {};

  // 全局记忆：记录5个位置的颜色选择（Pod 1-5）
  final List<TalkiePodsBean?> _globalColorMemory = List.filled(5, null, growable: false);

  // 当前选择的耳机总数量
  int _selectedQuantity = 0;

  // 用于滚动到设备选择标题的 key
  final GlobalKey _selectTitleKey = GlobalKey();

  // 从价格配置中获取数据
  List<TalkiePodsPrice> options = [];
  PriceConfiguration? priceConfig;

  // ���用的颜色选项
  final List<TalkiePodsBean> availableColors = TalkiePodsBean.variants;

  int _currentModelImageIndex = 0; // 当前模型图片索引
  final SwiperController _swiperController = SwiperController(); // 轮播图控制器
  int _platinumFamilyOwnerDue = 0; // platinumDue 时间戳

  @override
  void initState() {
    super.initState();

    // 监听 userType 变化，重新加载价格配置
    UserTypeManager().userTypeNotifier.addListener(_onUserTypeChanged);

    // 初始化价格配置
    _loadPriceConfig();

    // 恢复之前的耳机选择状态
    _restorePreviousSelection();

    TrackerManager.payShow();
    if (preRegisterMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final hasOrder = await _queryUnregisteredOrder();
        if (hasOrder) {
          _showGoRegisterDialog();
        }
      });
    }
    queryNewH5Result();
  }

  void queryNewH5Result() {
    JsBridgeManager.queryNewH5Result(callback: (Map responseMap) {
      consoleLog('openH5NewUrlResult: map $responseMap');
      if (preRegisterMode) {
        NavUtils.pushReplacement(context, PreEmptyPage(
          sessionId: responseMap['sessionId'],
          productId: responseMap['productId'],
        ));
      } else {
        NavUtils.pushReplacement(context, TalkiePodsMembershipActivationPage(
          sessionId: responseMap['sessionId'],
          productId: responseMap['productId'],
          vipUser: responseMap['vipUser'],
        ));
      }
    });
  }

  @override
  void dispose() {
    // 移除监听器
    UserTypeManager().userTypeNotifier.removeListener(_onUserTypeChanged);
    super.dispose();
  }

  /// 当 userType 变化时触发
  void _onUserTypeChanged() {
    if (mounted) {
      setState(() {
        _loadPriceConfig();
      });
    }
  }

  /// 加载价格配置
  void _loadPriceConfig() {
    final currentUserType = UserTypeManager().userType;
    // 同步获取价格配置
    priceConfig = PriceConfigManager.instance.getConfigByUserTypeSync(currentUserType);

    // 根据黑五模式限制最大数量
    final int maxQuantity = blackFridayModeEnabled ? 5 : 3;

    // 从价格配置生成选项列表
    if (priceConfig != null) {
      options = priceConfig!.talkiePods
          .where((price) => price.quantity <= maxQuantity) // 根据黑五模式过滤
          .toList();
    } else {
      // 如果配置不存在，使用空列表
      options = [];
    }
  }

  /// 从全局变量恢复之前的耳机选择状态
  void _restorePreviousSelection() {
    if (talkiesPodsList == null) {
      consoleLog('$_tag: No previous selection to restore');
      return;
    }

    consoleLog('$_tag: Restoring previous selection: $talkiesPodsList');

    try {
      // 如果是空数组，说明用户之前选择了"无设备"选项
      if (talkiesPodsList!.isEmpty) {
        // 获取当前用户类型
        final currentUserType = UserTypeManager().userType;

        // 只有非 planPlatinumFamily 用户才能选择"无设备"选项
        if (currentUserType != UserType.planPlatinumFamily) {
          // "无设备"选项的索引是 options.length（最后一个）
          _selectedIndex = options.length;
          _selectedQuantity = 0;
          consoleLog('$_tag: Successfully restored "No device" selection');
        } else {
          consoleLog('$_tag: planPlatinumFamily user cannot select "No device"');
        }
        return;
      }

      // 计算总数量并构建颜色列表
      int totalQuantity = 0;
      List<TalkiePodsBean> selectedColorsList = [];

      for (var item in talkiesPodsList!) {
        String color = item['color'] as String;
        int quantity = item['quantity'] as int;
        totalQuantity += quantity;

        // 根据 color 查找对应的 TalkiePodsBean
        TalkiePodsBean? colorBean = TalkiePodsBean.variants.firstWhere(
          (bean) => bean.color == color,
          orElse: () => TalkiePodsBean.variants[0], // 默认使用第一个颜色
        );

        // 将该颜色添加到列表中，重复 quantity 次
        for (int i = 0; i < quantity; i++) {
          selectedColorsList.add(colorBean);
        }
      }

      // 查找匹配的选项索引
      int? matchingIndex;
      for (int i = 0; i < options.length; i++) {
        if (options[i].quantity == totalQuantity) {
          matchingIndex = i;
          break;
        }
      }

      if (matchingIndex != null && totalQuantity <= 5) {
        // 设置选中的索引和数量
        _selectedIndex = matchingIndex;
        _selectedQuantity = totalQuantity;

        // 恢复颜色选择
        _selectedColors[matchingIndex] = selectedColorsList;

        // 更新全局记忆
        for (int i = 0; i < selectedColorsList.length && i < 5; i++) {
          _globalColorMemory[i] = selectedColorsList[i];
        }

        consoleLog('$_tag: Successfully restored selection: quantity=$totalQuantity, index=$matchingIndex');
      } else {
        consoleLog('$_tag: Could not find matching option for quantity: $totalQuantity');
      }
    } catch (e) {
      consoleLog('$_tag: Error restoring previous selection: $e');
    }
  }

  // 初始化或重置选中的颜色列表
  void _initializeSelectedColors(int itemIndex, int count) {
    // 如果列表不存在或数量不匹配，重新生成
    if (_selectedColors[itemIndex] == null || _selectedColors[itemIndex]!.length != count) {
      final defaultColor = availableColors[0]; // 绿色作为默认
      _selectedColors[itemIndex] = List<TalkiePodsBean>.generate(
        count,
        (index) => _globalColorMemory[index] ?? defaultColor,
        growable: false,
      );
    } else {
      // 列表已存在且数量匹配，同步全局记忆到当前列表
      for (int i = 0; i < count; i++) {
        if (_globalColorMemory[i] != null) {
          _selectedColors[itemIndex]![i] = _globalColorMemory[i]!;
        }
      }
    }
  }

  // 颜色圆圈组件，使用图片
  Widget _buildColorCircle(TalkiePodsBean colorBean, {bool isSelected = false}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? JTColorStyle.primaryTextColor : Colors.transparent,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          colorBean.icon,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 构建颜色选择器行 (用于选中项下方展开的内容)
  Widget _buildColorSelectorRow(TalkiePodsPrice option, int itemIndex) {
    // 初始化颜色列表
    _initializeSelectedColors(itemIndex, option.quantity);
    List<TalkiePodsBean> currentSelections = _selectedColors[itemIndex]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(option.quantity, (podIndex) {
          String color = currentSelections[podIndex].name(loc);
          String colorLabel = option.quantity > 1 ? getSelectStr(podIndex + 1, color) : sprintf(loc.talkiePodsSelectAFormat,[color]);
          return Container(
            padding: EdgeInsets.only(top: podIndex > 0 ? 10.0 : 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colorLabel,
                  style: JTTextStyle.titleSmall.copyWith(color: JTColorStyle.secondaryTextColor),
                ),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child:
                Wrap(
                  spacing: 8, // 水平间距
                  runSpacing: 8, // 垂直间距（换行后的行间距）
                  alignment: WrapAlignment.start,
                  children: availableColors.map((colorBean) {
                    bool isSelected = currentSelections[podIndex].color ==
                        colorBean.color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentSelections[podIndex] = colorBean;
                          _selectedColors[itemIndex] = currentSelections;
                          // 更新全局记忆
                          _globalColorMemory[podIndex] = colorBean;
                          // 切换轮播图到对应颜色
                          int colorIndex = availableColors.indexOf(colorBean);
                          if (colorIndex != -1) {
                            _swiperController.move(colorIndex);
                          }
                        });
                      },
                      child: _buildColorCircle(
                          colorBean, isSelected: isSelected),
                    );
                  }).toList(),
                )
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  // 构建列表中的每一项
  Widget _buildOptionTile(TalkiePodsPrice option, int index) {
    bool isSelected = _selectedIndex == index;
    bool isBlackFridayOption = option.quantity >= 4;

    // 更新选中的数量
    if (isSelected) {
      _selectedQuantity = option.quantity;
    }

    // 构建内容部分
    Widget contentWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 价格信息部分
        Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBlackFridayOption)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Image.asset(ImageLibrary.imgFire, height: 16),
                      const SizedBox(width: 2),
                      Text(
                        loc.blackFridaySpecial,
                        style: JTTextStyle.titleSmall.copyWith(color: Color(0xffFF2C55)),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${option.quantity} ${StaticStringLibrary.talkiePods}',
                      style: JTTextStyle.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Row(
                    children: [
                      Text(
                          option.originalPrice,
                          style: JTTextStyle.labelLarge.copyWith(
                              color: JTColorStyle.secondaryTextColor,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: JTColorStyle.secondaryTextColor)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        option.finalPrice,
                        style: JTTextStyle.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // 展开的颜色选择器部分 - 添加动画
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: value,
                child: child,
              ),
            );
          },
          child: _buildColorSelectorRow(option, index),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          // 只允许切换到其他选项，不允许反选
          _selectedIndex = index;
          // 更新选中的数量
          _selectedQuantity = option.quantity;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 5,
              ),
          ],
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0894FF), Color(0xFFBE46FF)],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: isBlackFridayOption
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE3F7FF), Color(0xFFFFEEF7)],
                          )
                        : null,
                    color: isBlackFridayOption ? null : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: contentWidget,
                ),
              )
            : Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: isBlackFridayOption
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE3F7FF), Color(0xFFFFEEF7)],
                        )
                      : null,
                  color: isBlackFridayOption ? null : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: contentWidget,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isWebDesignMode) {
      loc = AppLocalizations.of(context)!;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isTablet = constraints.maxWidth >= cTabletMinWidth;
            bool isLandscape = constraints.maxWidth > constraints.maxHeight;
            if (isTablet) {
              return _buildTabletLayout(constraints, isLandscape);
            } else {
              return buildCommon(false);
            }
          }),
    );
  }

  // 平板分屏布局
  Widget _buildTabletLayout(BoxConstraints constraints, bool isLandscape) {
    const double rightPaneWidth = 400.0;
    final double leftPaneWidth = constraints.maxWidth - rightPaneWidth - 1;
    return Column(children: [
      Center(
        child: Container(
          height: CommonUtil.getTopBarHeight(context),
          margin: EdgeInsets.only(top: CommonUtil.getSafeBarTop(), bottom: 20),
          alignment: Alignment.center,
          child: Text(
            titlePlatinumFamilyOwnerDue,
            style: JTTextStyle.titleSmall,
          ),
        ),
      ),
      Expanded(child:  Row(
        children: [
          // 左侧布局
          SizedBox(
            width: leftPaneWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    _buildTitlePlatinumFamily(isTablet: true),
                    Text(
                      loc.tipAvailableArea,
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedContainer(
                              noPadding: true,
                              targetMaxWidth: (!isLandscape || leftPaneWidth < cLandScapeTalkiePodsMaxWidth) ? 0 : cLandScapeTalkiePodsMaxWidth,
                              child: _buildProductImage(isTablet: true, isLandscape: isLandscape)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 右侧分屏 - 固定宽度，可滑动内容
          Container(
            width: 1.0,
            color: Color(0xffE5E5E5),
          ),
          Container(
            width: rightPaneWidth,
            color: Colors.white,
            child: buildCommon(true, isLandscape: isLandscape),
          ),
        ],
      ))
    ],);
  }

  Widget _buildTitlePlatinumFamily({bool isTablet = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: isTablet
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Text(
              StaticStringLibrary.platinumFamily,
              style: JTTextStyle.headlineSmall,
            )
        ),
        SizedBox(width: 8.0),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(ImageLibrary.imgWithDevice),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            loc.withDevice,
            style: JTTextStyle.labelMedium.copyWith(color: Color(0xFFFFEE00)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatinumFeaturePrice() {
    final currentUserType = UserTypeManager().userType;
    // 判断是否选择了"No device"选项
    bool isNoDevice = _selectedIndex != null && _selectedIndex! >= options.length && _selectedQuantity == 0;

    // 根据选择状态决定显示的文案和价格
    String displayText = loc.oneYearPlatinumFamily;
    String displayPrice = PriceConfigManager.instance.getPlatinumPrice();

    return Row(
      children: [
        Image.asset(ImageLibrary.icPlatinumFamilyLogo, height: 60),
        const SizedBox(width: 12),
        if (!isNoDevice && currentUserType != UserType.planOthers)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: JTTextStyle.titleMedium,
                ),
                Text(
                  loc.freePlatinumFamilySubtitle,
                  style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: Text(
              displayText,
              style: JTTextStyle.titleMedium,
            ),
          ),

        Text(
          displayPrice,
          style: JTTextStyle.labelLarge,
        ),
      ],
    );
  }

  Widget _buildPlatinumFeatureDuration() {
    return Row(
      children: [
        Image.asset(ImageLibrary.icBouns, height: 60),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.memberUpgradeBonus, style: JTTextStyle.titleMedium),
              Text(
                loc.memberUpgradeBonusSubtitle,
                style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 产品区域标题
  Widget _buildProductTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                StaticStringLibrary.talkiePods,
                style: JTTextStyle.headlineSmall2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          loc.madeByGiznity,
          style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
        ),
      ],
    );
  }

  /// 产品图片区域
  Widget   _buildProductImage({bool isTablet = false, bool isLandscape = false}) {
    double circleMargin = isTablet ? (isLandscape ? 32 : 100) : 12;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: isTablet ? 0.96 : 4 / 3,
          child: Swiper(
            controller: _swiperController,
            itemBuilder: (BuildContext context, int index) {
              String image = isTablet ? TalkiePodsBean.variants[index].imagePad
                  : TalkiePodsBean.variants[index].image;
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  child: ImageUtil.loadLocalImage(
                    context,
                    image,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ));
            },
            itemCount: TalkiePodsBean.variants.length,
            autoplay: false, // 不自动切换
            loop: true,
            onIndexChanged: (index) {
              setState(() {
                _currentModelImageIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: circleMargin),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: TalkiePodsBean.variants.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentModelImageIndex == entry.key
                    ? Colors.black
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    final currentUserType = UserTypeManager().userType;
    String allPrice = PriceConfigManager.instance.getTalkiePodsMemberSalePrice(currentUserType, _selectedQuantity);
    String allOriginalPrice = PriceConfigManager.instance.getTalkiePodsMemberOriginalPrice(currentUserType, _selectedQuantity);
    // 判断是否选择了"No device"选项
    bool isNoDevice = _selectedIndex != null &&
                      _selectedIndex! >= options.length &&
                      _selectedQuantity == 0;
    return Flexible(
      child: _selectedIndex != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 只在非"No device"选项时显示价格和划线价格
            if (!isNoDevice)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                      child: Text(allPrice,
                          style: JTTextStyle.titleMedium.copyWith(color: Color(0xFFEB445A)))
                  ),
                  SizedBox(width: 2),
                  Text(
                    allOriginalPrice,
                    style: JTTextStyle.titleMedium.copyWith(
                        color: JTColorStyle.secondaryTextColor,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: JTColorStyle.secondaryTextColor),
                  ),
                ],
              ),
            // "No device"选项显示价格
            if (isNoDevice)
              Text(
                allPrice,
                style: JTTextStyle.titleMedium.copyWith(color: Color(0xFFEB445A)),
              ),
            // 描述文本
            Text(
              isNoDevice ? loc.platinumOnly : (currentUserType == UserType.planPlatinumFamily
                      ? sprintf(loc.talkiePodsQtyFormat,[_selectedQuantity])
                      : sprintf(loc.talkiePodsMemberFormat,[_selectedQuantity])),
              style: JTTextStyle.bodyMedium,
            ),
          ],
        ) :
          Text(
            loc.talkiePodsSelect,
            style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
          ),
    );
  }

  Widget buildPromoTip(bool isTablet, String message) {
    return Container(
        width: double.infinity,
        height: 32,
        color: Color(0xCCFFEEE0),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
        child: ConstrainedContainer(
            noPadding: true,
            child: Center(
                child: ConstrainedContainer(
                    noPadding: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          ImageLibrary.icGift,
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 2),
                        Flexible(
                          child: HorizontalGradientText(
                            message,
                            style: JTTextStyle.titleSmall,
                            textAlign: TextAlign.center,
                            colors: const [
                              Color(0xFF3015FF),
                              Color(0xFFB515FF),
                              Color(0xFFFF1524),
                              Color(0xFFFF9000)
                            ],
                          ),
                        ),
                      ],
                    ))))
    );
  }

  /// 构建 talkiesPods 参数
  List<Map<String, dynamic>> _buildTalkiesPodsParams() {
    // 如果没有选择耳机或选择数量为0，返回空列表
    if (_selectedIndex == null || _selectedQuantity == 0 || _selectedIndex! >= options.length) {
      return [];
    }
    // 获取当前选择的颜色列表
    List<TalkiePodsBean>? selectedColorsList = _selectedColors[_selectedIndex!];
    // 如果没有颜色选择数据，返回空列表
    if (selectedColorsList == null || selectedColorsList.isEmpty) {
      return [];
    }
    // 按颜色分组统计数量
    Map<String, Map<String, dynamic>> colorMap = {};
    for (var talkiePod in selectedColorsList) {
      String color = talkiePod.color;
      if (colorMap.containsKey(color)) {
        // 该颜色已存在，数量 +1
        colorMap[color]!['quantity'] = (colorMap[color]!['quantity'] as int) + 1;
      } else {
        // 该颜色首次出现
        colorMap[color] = {
          "productId": talkiePod.priceId,
          "color": talkiePod.color,
          "quantity": 1
        };
      }
    }
    return colorMap.values.toList();
  }

  /// 耳机选择弹框
  void showSelectDialog() {
    DialogManager.showCommonDialog(
      context: context,
      titleStr: "${loc.talkiePodsSelect}.",
      onConfirm: () {
        Navigator.of(context).pop();
        // 弹窗关闭后，滚动到设备选择标题位置（对应初始位置的 _buildTitlePlatinumFamily）
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_selectTitleKey.currentContext != null) {
            final scrollable = Scrollable.of(_selectTitleKey.currentContext!);
            final viewportHeight = scrollable.position.viewportDimension;
            final alignment = 90 / viewportHeight;
            Scrollable.ensureVisible(
              _selectTitleKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: alignment
            );
          }
        });
      },
    );
  }

  /// 未选择设备弹框
  void showNoDeviceDialog(bool isTablet) {
    DialogManager.showCommonDialog(
      context: context,
      showCancelButton: true,
      titleStr: loc.confirmPurchaseTitle,
      messageStr: loc.confirmPurchaseMessage,
      confirmStr: loc.dialogConfirm,
      onConfirm: () {
        Navigator.of(context).pop();
        _handleCheckout(isTablet);
      },
    );
  }

  void _handleCheckout(bool isTablet) {
    String successRoute = preRegisterMode ? AppRoutes.preSignupEmpty : AppRoutes.payResultEmpty;
    if (isWebDesignMode) {
      NavUtils.pushNamed(context, successRoute, arguments: {'sessionId': 'test', 'productId': 'test'});
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, // 用户不能关闭弹框
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // 阻止返回键关闭弹框
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            content: Container(
              width: CommonUtil.commonDialogWidth(context),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.preparingCheckout,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // 根据是否选择了耳机颜色决定会员商品 ID
    final bool withHeadphones = _selectedQuantity > 0;
    final String productId = ProductConfig.getProductId(withHeadphones);
    final vipUser = UserTypeManager().userType != UserType.planOthers ? 'true' : "false";
    final Map<String, String> metadata = {};
    metadata['bluetoothMac'] = macAddress;

    /// 带上埋点
    final Map<String, dynamic> map = Map<String, dynamic>.from(traceDataMap);
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;

    /// 带上耳机数量、颜色、产品 id
    final List<Map<String, dynamic>> talkiesPodsParams = _buildTalkiesPodsParams();
    talkiesPodsList = talkiesPodsParams.isNotEmpty ? talkiesPodsParams : null;

    final Map<String, dynamic> orderParams = {
      'action': 'createOrder',
      'platform': 'stripe',
      'productId': productId,
      'successUrl': '${ProductConfig.myUrl}?page=$successRoute&productId=$productId&talkiesPods=${jsonEncode(talkiesPodsParams)}&trackerMap=${jsonEncode(traceDataMap)}&payResult=ok&vipUser=$vipUser',
      // 'cancelUrl': '${ProductConfig.myUrl}?page=${AppRoutes.productDetail}&talkiesPods=${jsonEncode(talkiesPodsParams)}',
      'test': isTestMode,
      'metadata': metadata.jsify(),
      'traceData': traceDataMap,
      'talkiesPods': talkiesPodsParams,
    };

    // 检查 WebViewJavascriptBridge 是否可用
    try {
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, orderParams.jsify(), (JSAny? responseData) {
        // 关闭加载弹框
        Navigator.of(context).pop();
        consoleLog('$_tag: responseData: $responseData');
        final Map? responseMap = jsAnyToMap(responseData);

        // 从响应中提取paymentLink并打开
        if (responseMap != null && responseMap.containsKey('paymentLink')) {
          final String? paymentLink = responseMap['paymentLink'] as String?;
          final String? sessionId = responseMap['sessionId'] as String?;
          if (paymentLink != null && paymentLink.isNotEmpty) {
            consoleLog('$_tag: opening payment link: $paymentLink');
            // 调用 loadingSuccess
            JsBridgeManager.loadingSuccess();
            TrackerManager.payClick(productId);
            consoleLog('$_tag: called loadingSuccess');
            if (CommonUtil.unSupportNewJs()) {
              CommonUtil.openUrl(paymentLink);
            } else {
              JsBridgeManager.startNewH5ForResult(CommonUtil.getFitSystemWindowsUrl(paymentLink));
              Future.delayed(Duration(milliseconds: 500), () {
                showPayConfirmDialog(productId,sessionId);
              });
            }
          } else {
            consoleLog('$_tag: paymentLink is null or empty');
            DialogManager.showErrorDialog(context: context, message: loc.tipNetworkError);
          }
        } else {
          consoleLog('$_tag: responseMap is null or does not contain paymentLink');
          DialogManager.showErrorDialog(context: context, message: loc.tipNetworkError);
        }
      }.toJS,
      );
    } catch (e) {
      // 关闭加载弹框
      Navigator.of(context).pop();
      consoleLog('$_tag: WebViewJavascriptBridge error: $e');
      DialogManager.showErrorDialog(context: context, message: loc.tipNetworkError);
    }
  }

  String getSelectStr(int quantity, String color) {
    if (quantity == 2) {
      return sprintf(loc.talkiePodsSelectTwoFormat, [color]);
    }
    else if (quantity == 3) {
      return sprintf(loc.talkiePodsSelectThreeFormat, [color]);
    }
    else if (quantity == 4) {
      return sprintf(loc.talkiePodsSelectFourFormat, [color]);
    }
    else if (quantity == 5) {
      return sprintf(loc.talkiePodsSelectFiveFormat, [color]);
    }
    else {
      return sprintf(loc.talkiePodsSelectOneFormat, [color]);
    }
  }

  Widget buildCommon(bool isTablet, { bool isLandscape = false}) {
    // 获取实时的 userType
    final currentUserType = UserTypeManager().userType;

    // 获取促销提示
    String? promoTip;

    // A 类用户：未选择或选择无设备时显示提示
    if (currentUserType == UserType.planOthers) {
      if (_selectedIndex == null || _selectedQuantity == 0) {
        promoTip = PriceConfigManager.instance.getPromoTip(
            userType: currentUserType,
            currentQty: 0,
            isBlackFriday: blackFridayModeEnabled
        );
      } else if (_selectedIndex! < options.length && _selectedQuantity > 0) {
        promoTip = PriceConfigManager.instance.getPromoTip(
            userType: currentUserType,
            currentQty: options[_selectedIndex!].quantity,
            isBlackFriday: blackFridayModeEnabled
        );
      }
    }
    // 其他类型：只有选择了有效的耳机选项才显示 promoTip
    else if (_selectedIndex != null && _selectedIndex! < options.length && _selectedQuantity > 0) {
      promoTip = PriceConfigManager.instance.getPromoTip(
          userType: currentUserType,
          currentQty: options[_selectedIndex!].quantity,
          isBlackFriday: blackFridayModeEnabled
      );
    }

    double padding = isTablet ? 24 : 20;
    // 计算底部悬浮区域的总高度（包含按钮区域的高度）
    double floatingBottomHeight = promoTip != null ? CommonUtil.getSafeBarBottom() + 110 + 32 + 24
                                                   : CommonUtil.getSafeBarBottom() + 110 + 24;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: floatingBottomHeight),
          child: Center(
            child: ConstrainedContainer(
                targetPadding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(!isTablet)...[
                      Container(
                        height: CommonUtil.getTopBarHeight(context),
                        margin: EdgeInsets.only(top: CommonUtil.getSafeBarTop(), bottom: 20),
                        alignment: Alignment.center,
                        child: Text(
                          titlePlatinumFamilyOwnerDue,
                          style: JTTextStyle.titleSmall,
                        ),
                      ),
                      _buildTitlePlatinumFamily(),
                      const SizedBox(height: 4),
                      Text(
                        loc.tipAvailableArea,
                        style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor)),
                      const SizedBox(height: 30),
                    ],
                    // 只在非 planPlatinumFamily 用户类型时显示会员价格
                    if (currentUserType != UserType.planPlatinumFamily) ...[
                      _buildPlatinumFeaturePrice(),
                      if(currentUserType != UserType.planOthers)...[
                        const SizedBox(height: 20),
                        _buildPlatinumFeatureDuration(),
                      ],
                      SizedBox(height: 40),
                    ],
                    _buildProductTitle(),
                    if(!isTablet)...[
                      const SizedBox(height: 20),
                      _buildProductImage(),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      key: _selectTitleKey,
                      '${loc.talkiePodsSelect}:',
                      style: JTTextStyle.titleMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 16.0),
                      // planPlatinumFamily 不显示"没有耳机"选项
                      itemCount: currentUserType == UserType.planPlatinumFamily
                          ? options.length
                          : options.length + 1,
                      itemBuilder: (context, index) {
                        if (index < options.length) {
                          return _buildOptionTile(options[index], index);
                        } else {
                          // "No device" 选项（仅非 planPlatinumFamily 用户显示）
                          bool isSelected = _selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                                // "No device" 选项的数量为0
                                _selectedQuantity = 0;
                              });
                            },
                            child: isSelected ? Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0894FF),
                                      Color(0xFFBE46FF)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Text(
                                    loc.noDevice,
                                    style: JTTextStyle.titleMedium,
                                  ),
                                ),
                              )
                                  : Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  loc.noDevice,
                                  style: JTTextStyle.titleMedium,
                                ),
                            ),
                          );
                        }
                      },
                    ),

                    if(currentUserType == UserType.planPlatinumFamily)...[
                      SizedBox(height: 16),
                      Text(
                          loc.platinumContactUs,
                          style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor)
                      ),
                    ],
                    const SizedBox(height: 32),
                    Image.asset(ImageLibrary.icShippingBoxGray),
                    SizedBox(height: 4),
                    Text(
                        loc.freeShipping,
                        style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor)
                    ),
                    SizedBox(height: 4),
                    Text(
                        currentUserType == UserType.planPlatinumFamily ? loc.platinumFreeShippingDesc : loc.freeShippingDesc,
                        style: JTTextStyle.bodyLarge.copyWith(color: JTColorStyle.secondaryTextColor)
                    ),
                    const SizedBox(height: 60),
                    // 订阅条款
                    Text(
                      loc.subscriptionTerms,
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    Text(
                      loc.paymentTerms,
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    Text(
                      loc.talkiePodsPolicy,
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    Text(
                      loc.talkiePodsPolicyDesc,
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    Text(
                      "${loc.terms}${StaticStringLibrary.termsUrl}",
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                    Text(
                      "${loc.privacyPolicy}${StaticStringLibrary.privacyUrl}",
                      style: JTTextStyle.bodyMedium.copyWith(color: JTColorStyle.secondaryTextColor),
                    ),
                  ],
                )
            ),
          ),
        ),
        // 底部按钮区悬浮，带背景模糊和分割线
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            child: ClipRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(children: [
                    if(promoTip != null)
                      buildPromoTip(isTablet,promoTip),
                    Container(
                      width: double.infinity,
                      height: CommonUtil.getSafeBarBottom() + 110,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.70)),
                      padding: EdgeInsets.fromLTRB(0, 16, 0, CommonUtil.getSafeBarBottom()),
                      child: Center(
                        child: ConstrainedContainer(
                          targetPadding: padding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 左侧价格信息
                              _buildPrice(),
                              const SizedBox(width: 16),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 11),
                                width: 133,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: JTColorStyle.themeColor,
                                    borderRadius: BorderRadius.circular(24.0)),
                                child: Text(
                                  loc.checkout,
                                  style: JTTextStyle.headlineSmall3.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],)
              ),
            ),
            onTap: () {
              _checkOrder(isTablet);
            },
          ),
        ),
      ],
    );
  }

  /// 预注册逻辑
  Map? unregisteredOrderParams;

  ///  查询是否有未注册待激活订单
  Future<bool> _queryUnregisteredOrder() async {
    final completer = Completer<bool>();
    final Map<String, dynamic> orderParams = {
      'action': 'queryPreSignupInactiveOrder',
      'eventType': 'platinumFamily',
    };
    try {
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, orderParams.jsify(), (JSAny? responseData) {
        consoleLog('$_tag: responseData: $responseData');
        final pendingOrderData = jsAnyToMap(responseData);
        if (pendingOrderData != null) {
          unregisteredOrderParams = pendingOrderData;
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      }.toJS);
    } catch (e) {
      consoleLog('$_tag: WebViewJavascriptBridge error: $e');
      completer.completeError(e);
    }
    return completer.future;
  }

  /// 提示去注册弹框
  void _showGoRegisterDialog() {
    DialogManager.showCommonDialog(
      context: context,
      titleStr: sprintf(loc.tipUnregisteredOrderFormat,[StaticStringLibrary.platinumFamily]),
      barrierDismissible: false,
      canPop: false,
      onConfirm: () {
        _reportUnregisteredOrder();
      },
    );
  }

  ///  上报未注册待激活订单
  void _reportUnregisteredOrder() {
    if (unregisteredOrderParams != null) {
      unregisteredOrderParams!['action'] = 'reportPreSignupInactiveOrder';
      final map = Map<String, dynamic>.from(traceDataMap);
      map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
      unregisteredOrderParams!['traceData'] = map;
      final String paramsJson = jsonEncode(unregisteredOrderParams);
      consoleLog('$_tag: 调用 reportPreSignupInactiveOrder 方法，参数: $paramsJson');
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.jsify(), null);
    }
  }

  Future<void> _checkOrder(bool isTablet) async {
    // 预注册模式：优先检查是否有未注册订单
    if (preRegisterMode) {
      final hasOrder = await _queryUnregisteredOrder();
      if (hasOrder) {
        _showGoRegisterDialog();
        return;
      }
    }

    if (_selectedIndex == null) { // 没有选择任何选项，显示提示
      showSelectDialog();
      return;
    }
    if (_selectedQuantity == 0) { // 选择无设备
      showNoDeviceDialog(isTablet);
      return;
    }
    _handleCheckout(isTablet);
  }

  void showPayConfirmDialog(String productId, String? sessionId) {
    DialogManager.showCommonDialog(
        context: context,
        titleStr: loc.payConfirmDialogTitle,
        confirmStr: loc.payConfirmDialogButtonDone,
        cancelStr: loc.payConfirmDialogButtonUnDone,
        barrierDismissible: false,
        canPop: false,
        showCancelButton: true,
        onConfirm: () {
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogDone);
          DialogManager.showLoadingDialog();
          _callPurchaseMethod(productId,sessionId);
        },
        onCancel: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogUnDone);
          showPayUnDoneDialog(productId,sessionId);
        }
    );
  }

  void showPayUnDoneDialog(String productId, String? sessionId) {
    DialogManager.showThreeButtonDialog(
        context: context,
        titleStr: loc.payUnDoneDialogTitle,
        primaryStr: loc.payUnDoneDialogButtonContinue,
        secondaryStr: loc.payUnDoneDialogButtonAbandon,
        tertiaryStr: loc.payUnDoneDialogButtonFeedback,
        barrierDismissible: false,
        canPop: false,
        onPrimary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogContinue);
          _handleCheckout(CommonUtil.isTablet(context));
        },
        onSecondary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogAbandon);
        },
        onTertiary: () {
          Navigator.of(context).pop();
          TrackerManager.payResultDialog(TrackerConstants.eventValuePayResultDialogFeedback);
          CommonUtil.openUrl(UrlConstants.feedbackUrlWithLabel);
        }
    );
  }

  /// 调用JS purchase方法
  void _callPurchaseMethod(String productId, String? sessionId) {
    final map = Map<String, dynamic>.from(traceDataMap);
    map['action'] = TrackerConstants.eventValueActionUserReport;
    map['type'] = TrackerConstants.eventValueMembershipPlatinumFamily;
    map['product'] = productId;
    final talkiePodsColor = TrackerManager.getTalkiePodsColor();
    if (talkiePodsColor != null) {
      map['talkiePodsColor'] = talkiePodsColor;
    }
    try {
      final Map<String, dynamic> purchaseParams = {
        'action': 'purchase',
        'productId': productId,
        'token': sessionId,
        'eventType': 'platinumFamily',
        'traceData': map,
        'test': isTestMode,
      };
      final String paramsJson = jsonEncode(purchaseParams);
      consoleLog('$_tag: 调用purchase方法，参数: $paramsJson');
      webViewJavascriptBridge.callHandler('jtJsToApp'.toJS, paramsJson.jsify(), (JSAny? responseData) {
        consoleLog('$_tag: purchase方法响应: $responseData');
        DialogManager.dismissLoadingDialog();
        final Map<String, dynamic>? responseMap = jsAnyToMap(responseData);
        if (responseMap != null) {
          consoleLog('$_tag: purchase响应解析成功: $responseMap');
          if (responseMap.containsKey('platinumFamilyOwnerDue')) {
            final dynamic platinumFamilyOwnerDue = responseMap['platinumFamilyOwnerDue'];
            if (platinumFamilyOwnerDue is int) {
              _platinumFamilyOwnerDue = platinumFamilyOwnerDue;
              int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
              titlePlatinumFamilyOwnerDue = (_platinumFamilyOwnerDue > 0 && _platinumFamilyOwnerDue > currentTimeMillis) ? sprintf(loc.titlePlatinumExpiresOnFormat, [_platinumFamilyOwnerDue]) : "";
              consoleLog('$_tag: 更新platinumDue时间戳: $platinumFamilyOwnerDue');
            }
          }
          bool result = responseMap['result'] ?? false;
          if (result) {
            Navigator.of(context).pop();
            NavUtils.pushReplacement(context, TalkiePodsMembershipActivationPage(
              sessionId: sessionId,
              productId: productId,
              platinumFamilyOwnerDue: _platinumFamilyOwnerDue,
              result: true,
            ));
          } else {
            Navigator.of(context).pop();
            showPayUnDoneDialog(productId, sessionId);
          }
        } else {
          Navigator.of(context).pop();
          showPayUnDoneDialog(productId, sessionId);
        }
      }.toJS,
      );
    } catch (e) {
      DialogManager.dismissLoadingDialog();
      consoleLog('$_tag: 调用purchase方法失败: $e');
      Navigator.of(context).pop();
      showPayUnDoneDialog(productId, sessionId);
    }
  }

}


