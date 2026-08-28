import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../models/command_model.dart';
import 'device_admin_service.dart';
import 'accessibility_service.dart';

class SocketService {
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  final int port = 8080;
  
  Function(CommandModel)? onCommandReceived;

  // CHILD MODE: Act as a server listening for parent commands
  Future<void> startServer() async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket!.listen((Socket client) {
      _clientSocket = client;
      client.listen((List<int> data) {
        final message = utf8.decode(data);
        final command = CommandModel.fromJson(message);
        _handleChildCommand(command);
        if (onCommandReceived != null) onCommandReceived!(command);
      });
    });
  }

  // PARENT MODE: Connect to child's IP
  Future<bool> connectToChild(String ipAddress) async {
    try {
      _clientSocket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      _clientSocket!.listen((List<int> data) {
        final message = utf8.decode(data);
        if (onCommandReceived != null) {
          onCommandReceived!(CommandModel.fromJson(message));
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  void sendCommand(CommandModel command) {
    if (_clientSocket != null) {
      _clientSocket!.write(command.toJson());
    }
  }

  void _handleChildCommand(CommandModel command) async {
    switch (command.type) {
      case CommandType.lockDevice:
        await DeviceAdminService.lockScreen();
        break;
      case CommandType.blockApp:
        final package = command.payload?['package'];
        if (package != null) await AccessibilityService.blockApp(package);
        break;
      case CommandType.unblockApp:
        final package = command.payload?['package'];
        if (package != null) await AccessibilityService.unblockApp(package);
        break;
      case CommandType.requestLocation:
        // Handle via UI or geolocation service and send CommandType.sendLocation back
        break;
      default:
        break;
    }
  }

  void dispose() {
    _serverSocket?.close();
    _clientSocket?.close();
  }
}
