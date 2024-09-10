import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'enum/enums.dart';
import 'umspay_platform_interface.dart';

/// An implementation of [UmspayPlatform] that uses method channels.
class MethodChannelUmspay extends UmspayPlatform {
  static const String MESSAGE_CHANNEL_NAME = "com.jajs.umspay.message";

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('umspay');

  @visibleForTesting
  final messageChannel = const BasicMessageChannel<Object?>(
    MESSAGE_CHANNEL_NAME,
    StandardMessageCodec(),
  );

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  void umsPay({
    required UmsPayType type,
    required String payData,
    String? wechatAppId,
    String? universalLink,
    VoidCallback? onSuccess,
    ValueSetter? onFailure,
  }) {
    final reqParams = {};
    reqParams.putIfAbsent("channel", () => type.code);
    reqParams.putIfAbsent("payData", () => payData);
    reqParams.putIfAbsent("wechatAppId", () => wechatAppId);
    reqParams.putIfAbsent("universalLink", () => universalLink);
    methodChannel.invokeMethod("umsPay", reqParams);
    messageChannel.setMessageHandler(
      (message) {
        debugPrint(" === messageChannel.receive.message:$message === ");
        if (message is Map) {
          final errCode = message["errCode"];
          final errStr = message["errStr"];
          debugPrint(
              " === errCode:${errCode.toString()} errStr:${errStr.toString()} === ");
          if (errCode == "0000") {
            // 成功
            onSuccess?.call();
          } else {
            // 失败
            debugPrint(" === 失败失败失败失败 === ");
            onFailure?.call(errStr);
          }
        }
        return Future(() => "from dart");
      },
    );
  }
}
