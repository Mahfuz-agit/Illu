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
      title: 'Parental Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ModeSelectorScreen(),
    );
  }
}

class ModeSelectorScreen extends StatelessWidget {
  const ModeSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Device Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings, size: 30),
              label: const Text("I am the Parent", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParentScreen())),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.child_care, size: 30),
              label: const Text("I am the Child", style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChildScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
