import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../models/command_model.dart';

class ParentScreen extends StatefulWidget {
  @override
  _ParentScreenState createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _ipController = TextEditingController();
  bool _isConnected = false;
  String _childLocation = "Unknown";

  @override
  void initState() {
    super.initState();
    _socketService.onCommandReceived = (command) {
      if (command.type == CommandType.sendLocation) {
        setState(() {
          _childLocation = "${command.payload?['lat']}, ${command.payload?['lng']}";
        });
      }
    };
  }

  void _connect() async {
    bool success = await _socketService.connectToChild(_ipController.text);
    setState(() {
      _isConnected = success;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Parent Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Child Device IP Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isConnected ? null : _connect,
              child: Text(_isConnected ? 'Connected' : 'Connect'),
            ),
            const Divider(height: 40),
            if (_isConnected) ...[
              ListTile(
                title: const Text("Lock Child Screen"),
                trailing: const Icon(Icons.lock),
                onTap: () {
                  _socketService.sendCommand(CommandModel(type: CommandType.lockDevice));
                },
              ),
              ListTile(
                title: const Text("Block YouTube"),
                trailing: const Icon(Icons.block),
                onTap: () {
                  _socketService.sendCommand(CommandModel(
                    type: CommandType.blockApp,
                    payload: {'package': 'com.google.android.youtube'},
                  ));
                },
              ),
              ListTile(
                title: const Text("Request Location"),
                subtitle: Text("Current: $_childLocation"),
                trailing: const Icon(Icons.location_on),
                onTap: () {
                  _socketService.sendCommand(CommandModel(type: CommandType.requestLocation));
                },
              ),
            ]
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
