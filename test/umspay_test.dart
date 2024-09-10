import 'package:flutter_test/flutter_test.dart';
import 'package:umspay/umspay.dart';
import 'package:umspay/umspay_platform_interface.dart';
import 'package:umspay/umspay_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUmspayPlatform
    with MockPlatformInterfaceMixin
    implements UmspayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UmspayPlatform initialPlatform = UmspayPlatform.instance;

  test('$MethodChannelUmspay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUmspay>());
  });

  test('getPlatformVersion', () async {
    Umspay umspayPlugin = Umspay();
    MockUmspayPlatform fakePlatform = MockUmspayPlatform();
    UmspayPlatform.instance = fakePlatform;

    expect(await umspayPlugin.getPlatformVersion(), '42');
  });
}
