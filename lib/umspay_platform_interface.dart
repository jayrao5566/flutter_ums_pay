import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'enum/enums.dart';
import 'umspay_method_channel.dart';

abstract class UmspayPlatform extends PlatformInterface {
  /// Constructs a UmspayPlatform.
  UmspayPlatform() : super(token: _token);

  static final Object _token = Object();

  static UmspayPlatform _instance = MethodChannelUmspay();

  /// The default instance of [UmspayPlatform] to use.
  ///
  /// Defaults to [MethodChannelUmspay].
  static UmspayPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UmspayPlatform] when
  /// they register themselves.
  static set instance(UmspayPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void umsPay({
    required UmsPayType type,
    required String payData,
    String? wechatAppId,
    String? universalLink,
    VoidCallback? onSuccess,
    ValueSetter? onFailure,
  }) {
    throw UnimplementedError('umsPay() has not been implemented.');
  }
}
