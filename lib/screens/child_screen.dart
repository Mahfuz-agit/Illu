import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../services/socket_service.dart';
import '../services/device_admin_service.dart';
import '../services/accessibility_service.dart';
import '../models/command_model.dart';

class ChildScreen extends StatefulWidget {
  @override
  _ChildScreenState createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final SocketService _socketService = SocketService();
  String _ipAddress = "Loading...";

  @override
  void initState() {
    super.initState();
    _initNetwork();
    _socketService.startServer();
    
    _socketService.onCommandReceived = (command) async {
      if (command.type == CommandType.requestLocation) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        _socketService.sendCommand(CommandModel(
          type: CommandType.sendLocation,
          payload: {'lat': position.latitude, 'lng': position.longitude}
        ));
      }
    };
  }

  Future<void> _initNetwork() async {
    final info = NetworkInfo();
    final ip = await info.getWifiIP();
    setState(() {
      _ipAddress = ip ?? "Not connected to WiFi";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: 'blue'),
            const SizedBox(height: 20),
            Text("Your IP: $_ipAddress", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Enter this IP in the Parent App to connect.", textAlign: TextAlign.center),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () => DeviceAdminService.requestAdminPrivileges(),
              child: const Text("Enable Device Admin (Lock)"),
            ),
            ElevatedButton(
              onPressed: () => AccessibilityService.requestAccessibility(),
              child: const Text("Enable Accessibility (App Block)"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
