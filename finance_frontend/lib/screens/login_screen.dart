import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onRegister;
  const LoginScreen({super.key, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF3B82F6), size: 48),
                  const SizedBox(height: 16),
                  const Text('Finance Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Sign in to your account',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                  const SizedBox(height: 32),
                  _buildField('Username', _usernameCtrl, Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildField('Password', _passwordCtrl, Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF64748B)),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: widget.onRegister,
                      child: const Text("Don't have an account? Register",
                          style: TextStyle(color: Color(0xFF3B82F6))),
                    ),
                  ),
                  const Divider(color: Color(0xFF334155), height: 32),
                  const Text('Demo Accounts:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  const SizedBox(height: 8),
                  _demoAccount('admin / admin123', 'ADMIN'),
                  _demoAccount('analyst / analyst123', 'ANALYST'),
                  _demoAccount('viewer / viewer123', 'VIEWER'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoAccount(String creds, String role) {
    final colors = {'ADMIN': Colors.red, 'ANALYST': Colors.orange, 'VIEWER': Colors.green};
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors[role]!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(role, style: TextStyle(color: colors[role], fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Text(creds, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6)),
            ),
          ),
          validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }
}
