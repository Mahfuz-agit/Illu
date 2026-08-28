import 'package:flutter/services.dart';

class DeviceAdminService {
  static const MethodChannel _channel = MethodChannel('com.example.parental_control_app/device_admin');

  static Future<bool> requestAdminPrivileges() async {
    try {
      final bool result = await _channel.invokeMethod('requestAdmin');
      return result;
    } on PlatformException catch (e) {
      print("Failed to request admin: '${e.message}'.");
      return false;
    }
  }

  static Future<void> lockScreen() async {
    try {
      await _channel.invokeMethod('lockScreen');
    } on PlatformException catch (e) {
      print("Failed to lock screen: '${e.message}'.");
    }
  }
}
