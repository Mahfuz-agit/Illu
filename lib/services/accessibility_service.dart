import 'package:flutter/services.dart';

class AccessibilityService {
  static const MethodChannel _channel = MethodChannel('com.example.parental_control_app/accessibility');

  static Future<bool> isAccessibilityEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('checkAccessibility');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestAccessibility() async {
    try {
      await _channel.invokeMethod('requestAccessibility');
    } on PlatformException catch (e) {
      print("Failed to request accessibility: '${e.message}'.");
    }
  }

  static Future<void> blockApp(String packageName) async {
    try {
      await _channel.invokeMethod('blockApp', {'package': packageName});
    } on PlatformException catch (e) {
      print("Failed to block app: '${e.message}'.");
    }
  }

  static Future<void> unblockApp(String packageName) async {
    try {
      await _channel.invokeMethod('unblockApp', {'package': packageName});
    } on PlatformException catch (e) {
      print("Failed to unblock app: '${e.message}'.");
    }
  }
}
