import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLogin;
  const RegisterScreen({super.key, required this.onLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'VIEWER';
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
        _usernameCtrl.text.trim(), _passwordCtrl.text, _emailCtrl.text.trim(), _role);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: Colors.red),
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
                  const Text('Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Register to get started',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                  const SizedBox(height: 32),
                  _buildField('Username', _usernameCtrl, Icons.person_outline,
                      validator: (v) => v == null || v.length < 3 ? 'Min 3 characters' : null),
                  const SizedBox(height: 16),
                  _buildField('Email', _emailCtrl, Icons.email_outlined,
                      validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null),
                  const SizedBox(height: 16),
                  _buildField('Password', _passwordCtrl, Icons.lock_outline,
                      obscure: _obscure,
                      validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF64748B)),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )),
                  const SizedBox(height: 16),
                  const Text('Role', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _role,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        isExpanded: true,
                        items: ['VIEWER', 'ANALYST', 'ADMIN'].map((r) =>
                          DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: widget.onLogin,
                      child: const Text('Already have an account? Sign In',
                          style: TextStyle(color: Color(0xFF3B82F6))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false, Widget? suffix, String? Function(String?)? validator}) {
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF334155))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF334155))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF3B82F6))),
          ),
          validator: validator ?? (v) => v == null || v.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }
}
