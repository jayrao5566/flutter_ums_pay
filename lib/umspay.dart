import 'package:flutter/cupertino.dart';

import 'enum/enums.dart';
import 'umspay_platform_interface.dart';

class Umspay {
  Future<String?> getPlatformVersion() {
    return UmspayPlatform.instance.getPlatformVersion();
  }

  Future<bool?> installed({
    required AppPayMode payMode,
  }) {
    // 判断app是否安装
    return UmspayPlatform.instance.installed(payMode: payMode);
  }

  /// 银联商务天满支付系统
  void umsPay({
    required UmsPayType type,
    required String payData,
    String? wechatAppId,
    String? universalLink,
    VoidCallback? onSuccess,
    ValueSetter? onFailure,
  }) {
    UmspayPlatform.instance.umsPay(
      type: type,
      payData: payData,
      wechatAppId: wechatAppId,
      universalLink: universalLink,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }

  /// 云闪付
  void cloundPay({
    required String? urlScheme, // ios配置
    required String payData,
    String env = "00", // 安卓配置
    VoidCallback? onSuccess,
    ValueSetter? onFailure,
  }) {
    UmspayPlatform.instance.cloundPay(
      urlScheme: urlScheme,
      payData: payData,
      env: env,
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
}
