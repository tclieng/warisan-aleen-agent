import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_client.dart';
import 'screens/dashboard_screen.dart';
import 'screens/generate_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const WarisanApp());

class WarisanApp extends StatelessWidget {
  const WarisanApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ApiClient(),
        child: MaterialApp(
          title: 'Warisan Aleen AI Agent',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF14301C), // kampung deep green
              secondary: const Color(0xFFF5EBD2), // cream rice
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        ),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;
  final _tabs = const [
    DashboardScreen(),
    GenerateScreen(),
    QueueScreen(),
    SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: _tabs[_idx],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Generate'),
            NavigationDestination(icon: Icon(Icons.schedule), label: 'Queue'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      );
}
