import 'dart:io';
import 'dart:convert';
import '../models/command_model.dart';

class SocketService {
  ServerSocket? _server;
  Socket? _clientSocket;
  Function(CommandModel)? onCommandReceived;

  // ফিক্সড পোর্ট নম্বর (এটি চাইল্ড এবং প্যারেন্ট উভয় অ্যাপেই এক থাকতে হবে)
  final int port = 4040;

  // চাইল্ড ফোনে সার্ভার চালু করার জন্য
  Future<void> startServer() async {
    try {
      // InternetAddress.anyIPv4 ব্যবহার করা বাধ্যতামূলক যাতে হটস্পটের অন্য ডিভাইস থেকে কানেক্ট হতে পারে
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      print('Socket Server running on port $port');

      _server!.listen((Socket client) {
        _clientSocket = client;
        print('Parent connected successfully: ${client.remoteAddress.address}');

        client.listen(
          (data) {
            try {
              String jsonString = utf8.decode(data);
              Map<String, dynamic> jsonMap = jsonDecode(jsonString);
              CommandModel command = CommandModel.fromJson(jsonMap);
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

  // প্যারেন্ট ফোন থেকে চাইল্ডে কানেক্ট করার জন্য
  Future<bool> connectToChild(String ipAddress) async {
    try {
      // আইপির সাথে অবশ্যই ফিক্সড পোর্ট (যেমন: :4040) যুক্ত করতে হবে
      _clientSocket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      print('Connected to child at $ipAddress:$port');
      return true;
    } catch (e) {
      print('Connection failed: $e');
      return false;
    }
  }

  // কমান্ড পাঠানোর জন্য
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
