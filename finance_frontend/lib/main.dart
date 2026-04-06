import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/records_screen.dart';
import 'screens/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkSession(),
      child: const FinanceApp(),
    ),
  );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6)),
      ),
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) return const MainShell();
    return const AuthRouter();
  }
}

class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(onRegister: () => setState(() => _showLogin = false))
        : RegisterScreen(onLogin: () => setState(() => _showLogin = true));
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RecordsScreen(),
    UsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Color(0xFF3B82F6), size: 28),
                      SizedBox(width: 12),
                      Text('FinanceApp', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // Nav Items
                const SizedBox(height: 8),
                _navItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _navItem(1, Icons.receipt_long_outlined, 'Records'),
                if (auth.isAdmin) _navItem(2, Icons.people_outline, 'Users'),

                const Spacer(),

                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          (user?['username'] as String? ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?['username'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(user?['role'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFF64748B), size: 18),
                        onPressed: () => context.read<AuthProvider>().logout(),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF3B82F6) : const Color(0xFF64748B), size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(
              color: selected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}
