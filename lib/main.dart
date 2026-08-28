import 'package:flutter/material.dart';
import 'screens/parent_screen.dart';
import 'screens/child_screen.dart';

void main() {
  runApp(const ParentalControlApp());
}

class ParentalControlApp extends StatelessWidget {
  const ParentalControlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TicTacToe Classic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ModeSelectorScreen(),
    );
  }
}

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("Parent Control Mode"),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ParentScreen())),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.sports_esports),
              label: const Text("Start Child Mode (Game)"),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChildScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
