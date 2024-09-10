import 'package:flutter/cupertino.dart';

import 'enum/enums.dart';
import 'umspay_platform_interface.dart';

class Umspay {
  Future<String?> getPlatformVersion() {
    return UmspayPlatform.instance.getPlatformVersion();
  }

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
}
