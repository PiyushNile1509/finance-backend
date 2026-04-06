import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await ApiService.getUsers();
      setState(() { _users = users; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleStatus(int id, bool current) async {
    await ApiService.updateUserStatus(id, !current);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: Color(0xFF64748B), size: 48),
            SizedBox(height: 16),
            Text('Admin access required', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Management', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Manage user accounts and roles', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text('Username', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                              Expanded(flex: 3, child: Text('Email', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                              Expanded(flex: 1, child: Text('Role', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                              Expanded(flex: 1, child: Text('Status', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                              Expanded(flex: 2, child: Text('Created', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                              SizedBox(width: 80, child: Text('Action', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _users.length,
                            itemBuilder: (_, i) {
                              final u = _users[i];
                              final isActive = u['active'] == true;
                              final role = u['role'] as String;
                              final roleColors = {
                                'ADMIN': const Color(0xFFEF4444),
                                'ANALYST': const Color(0xFFF59E0B),
                                'VIEWER': const Color(0xFF10B981),
                              };
                              final roleBg = {
                                'ADMIN': const Color(0xFF7F1D1D),
                                'ANALYST': const Color(0xFF78350F),
                                'VIEWER': const Color(0xFF064E3B),
                              };
                              final createdAt = u['createdAt'] != null
                                  ? u['createdAt'].toString().substring(0, 10)
                                  : '-';
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFF0F172A))),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(0xFF334155),
                                          child: Text(
                                            (u['username'] as String)[0].toUpperCase(),
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(u['username'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      ],
                                    )),
                                    Expanded(flex: 3, child: Text(u['email'] ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
                                    Expanded(flex: 1, child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: roleBg[role],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(role, style: TextStyle(color: roleColors[role], fontSize: 11)),
                                    )),
                                    Expanded(flex: 1, child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isActive ? const Color(0xFF064E3B) : const Color(0xFF1F2937),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                                          fontSize: 11,
                                        ),
                                      ),
                                    )),
                                    Expanded(flex: 2, child: Text(createdAt, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))),
                                    SizedBox(
                                      width: 80,
                                      child: Switch(
                                        value: isActive,
                                        activeColor: const Color(0xFF10B981),
                                        onChanged: (_) => _toggleStatus(u['id'], isActive),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
