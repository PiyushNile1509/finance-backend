import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<dynamic> _records = [];
  bool _loading = true;
  int _page = 0;
  int _totalPages = 0;
  String? _filterType;
  final _categoryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getRecords(
        type: _filterType,
        category: _categoryCtrl.text.isEmpty ? null : _categoryCtrl.text,
        page: _page,
      );
      setState(() {
        _records = data['content'] ?? [];
        _totalPages = data['totalPages'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showForm({Map<String, dynamic>? record}) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAnalyst) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You do not have permission'), backgroundColor: Colors.red),
      );
      return;
    }
    showDialog(context: context, builder: (_) => _RecordFormDialog(record: record, onSaved: _load));
  }

  Future<void> _delete(int id) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can delete records'), backgroundColor: Colors.red),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Record', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteRecord(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Records', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Manage your transactions', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ],
              ),
              if (auth.isAnalyst)
                ElevatedButton.icon(
                  onPressed: () => _showForm(),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add Record', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterType,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Filter by Type'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Types')),
                      const DropdownMenuItem(value: 'INCOME', child: Text('Income')),
                      const DropdownMenuItem(value: 'EXPENSE', child: Text('Expense')),
                    ],
                    onChanged: (v) { setState(() { _filterType = v; _page = 0; }); _load(); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _categoryCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Filter by Category'),
                    onSubmitted: (_) { setState(() => _page = 0); _load(); },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () { setState(() => _page = 0); _load(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Search', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
                  : _records.isEmpty
                      ? const Center(child: Text('No records found', style: TextStyle(color: Color(0xFF64748B))))
                      : Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: Text('Date', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 2, child: Text('Category', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 1, child: Text('Type', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 2, child: Text('Amount', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                  Expanded(flex: 3, child: Text('Notes', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                  SizedBox(width: 80, child: Text('Actions', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _records.length,
                                itemBuilder: (_, i) {
                                  final r = _records[i];
                                  final isIncome = r['type'] == 'INCOME';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 2, child: Text(r['date'] ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
                                        Expanded(flex: 2, child: Text(r['category'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13))),
                                        Expanded(flex: 1, child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isIncome ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(r['type'], style: TextStyle(
                                            color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            fontSize: 11,
                                          )),
                                        )),
                                        Expanded(flex: 2, child: Text(
                                          fmt.format((r['amount'] as num).toDouble()),
                                          style: TextStyle(
                                            color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        )),
                                        Expanded(flex: 3, child: Text(r['notes'] ?? '-',
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        SizedBox(
                                          width: 80,
                                          child: Row(
                                            children: [
                                              if (auth.isAnalyst)
                                                IconButton(
                                                  icon: const Icon(Icons.edit, size: 16, color: Color(0xFF3B82F6)),
                                                  onPressed: () => _showForm(record: r),
                                                  tooltip: 'Edit',
                                                ),
                                              if (auth.isAdmin)
                                                IconButton(
                                                  icon: const Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)),
                                                  onPressed: () => _delete(r['id']),
                                                  tooltip: 'Delete',
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Pagination
                            if (_totalPages > 1)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: Color(0xFF334155))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                                      onPressed: _page > 0 ? () { setState(() => _page--); _load(); } : null,
                                    ),
                                    Text('Page ${_page + 1} of $_totalPages',
                                        style: const TextStyle(color: Color(0xFF94A3B8))),
                                    IconButton(
                                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                                      onPressed: _page < _totalPages - 1 ? () { setState(() => _page++); _load(); } : null,
                                    ),
                                  ],
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

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF64748B)),
    filled: true,
    fillColor: const Color(0xFF0F172A),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}

class _RecordFormDialog extends StatefulWidget {
  final Map<String, dynamic>? record;
  final VoidCallback onSaved;
  const _RecordFormDialog({this.record, required this.onSaved});

  @override
  State<_RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<_RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _type = 'INCOME';
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _amountCtrl.text = widget.record!['amount'].toString();
      _categoryCtrl.text = widget.record!['category'] ?? '';
      _notesCtrl.text = widget.record!['notes'] ?? '';
      _type = widget.record!['type'] ?? 'INCOME';
      _date = DateTime.parse(widget.record!['date']);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'amount': double.parse(_amountCtrl.text),
      'type': _type,
      'category': _categoryCtrl.text,
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'notes': _notesCtrl.text,
    };
    try {
      if (widget.record != null) {
        await ApiService.updateRecord(widget.record!['id'], data);
      } else {
        await ApiService.createRecord(data);
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.record != null ? 'Edit Record' : 'New Record',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _field('Amount', _amountCtrl,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid amount' : null,
                    keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
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
                          value: _type,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: ['INCOME', 'EXPENSE'].map((t) =>
                              DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ),
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 12),
              _field('Category', _categoryCtrl),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (_, child) => Theme(
                          data: ThemeData.dark(),
                          child: child!,
                        ),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF64748B), size: 16),
                          const SizedBox(width: 8),
                          Text(DateFormat('yyyy-MM-dd').format(_date),
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field('Notes (optional)', _notesCtrl, required: false),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(widget.record != null ? 'Update' : 'Create',
                            style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool required = true, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF334155))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: validator ?? (v) => required && (v == null || v.isEmpty) ? '$label is required' : null,
        ),
      ],
    );
  }
}
