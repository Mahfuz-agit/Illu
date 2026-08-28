import 'dart:io';
import 'dart:convert';
import '../models/command_model.dart';

class SocketService {
  ServerSocket? _server;
  Socket? _clientSocket;
  Function(CommandModel)? onCommandReceived;

  final int port = 4040;

  Future<void> startServer() async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print('Socket Server running on port $port');

      _server!.listen((Socket client) {
        _clientSocket = client;
        print('Parent connected successfully: ${client.remoteAddress.address}');

        client.listen(
          (data) {
            try {
              String jsonString = utf8.decode(data);
              CommandModel command = CommandModel.fromJson(jsonString);
              if (onCommandReceived != null) {
                onCommandReceived!(command);
              }
            } catch (e) {
              print('Error decoding command: $e');
            }
          },
          onDone: () {
            print('Parent disconnected');
            _clientSocket = null;
          },
          onError: (error) {
            print('Socket error: $error');
            _clientSocket = null;
          },
        );
      });
    } catch (e) {
      print('Error starting server: $e');
    }
  }

  Future<bool> connectToChild(String ipAddress) async {
    try {
      _clientSocket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      print('Connected to child at $ipAddress:$port');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  void sendCommand(CommandModel command) {
    if (_clientSocket != null) {
      String jsonString = jsonEncode(command.toJson());
      _clientSocket!.write(jsonString);
    } else {
      print('Socket is not connected');
    }
  }

  void dispose() {
    _server?.close();
    _clientSocket?.destroy();
  }
}
