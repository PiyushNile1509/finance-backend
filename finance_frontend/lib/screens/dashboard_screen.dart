import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDashboard();
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    if (_data == null) return const Center(child: Text('Failed to load', style: TextStyle(color: Colors.white)));

    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final income = (_data!['totalIncome'] as num).toDouble();
    final expenses = (_data!['totalExpenses'] as num).toDouble();
    final balance = (_data!['netBalance'] as num).toDouble();
    final categoryTotals = Map<String, dynamic>.from(_data!['categoryTotals'] ?? {});
    final recentActivity = List<dynamic>.from(_data!['recentActivity'] ?? []);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Financial Overview', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 24),

            // Summary Cards
            LayoutBuilder(builder: (context, constraints) {
              final crossAxis = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
              return GridView.count(
                crossAxisCount: crossAxis,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  _summaryCard('Total Income', fmt.format(income), Icons.trending_up, const Color(0xFF10B981), const Color(0xFF064E3B)),
                  _summaryCard('Total Expenses', fmt.format(expenses), Icons.trending_down, const Color(0xFFEF4444), const Color(0xFF7F1D1D)),
                  _summaryCard('Net Balance', fmt.format(balance), Icons.account_balance_wallet,
                      balance >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
                      balance >= 0 ? const Color(0xFF1E3A5F) : const Color(0xFF78350F)),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Charts Row
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _pieChart(income, expenses)),
                    const SizedBox(width: 16),
                    Expanded(child: _categoryChart(categoryTotals)),
                  ],
                );
              }
              return Column(children: [
                _pieChart(income, expenses),
                const SizedBox(height: 16),
                _categoryChart(categoryTotals),
              ]);
            }),

            const SizedBox(height: 24),
            _recentActivity(recentActivity, fmt),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pieChart(double income, double expenses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Income vs Expenses', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: income == 0 && expenses == 0
                ? const Center(child: Text('No data', style: TextStyle(color: Color(0xFF64748B))))
                : PieChart(PieChartData(
                    sections: [
                      PieChartSectionData(value: income, color: const Color(0xFF10B981),
                          title: 'Income', titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                      PieChartSectionData(value: expenses, color: const Color(0xFFEF4444),
                          title: 'Expenses', titleStyle: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  )),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('Income', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _legend('Expenses', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryChart(Map<String, dynamic> categoryTotals) {
    final entries = categoryTotals.entries.toList();
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF06B6D4),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Breakdown', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const Center(child: Text('No data', style: TextStyle(color: Color(0xFF64748B))))
          else
            ...entries.asMap().entries.map((e) {
              final idx = e.key;
              final entry = e.value;
              final total = categoryTotals.values.fold(0.0, (a, b) => a + (b as num).toDouble());
              final pct = total > 0 ? (entry.value as num).toDouble() / total : 0.0;
              final color = colors[idx % colors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                        Text('\$${(entry.value as num).toStringAsFixed(2)}',
                            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _recentActivity(List<dynamic> records, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No recent activity', style: TextStyle(color: Color(0xFF64748B))),
            ))
          else
            ...records.map((r) {
              final isIncome = r['type'] == 'INCOME';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isIncome ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['category'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                          Text(r['notes'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isIncome ? '+' : '-'}${fmt.format((r['amount'] as num).toDouble())}',
                          style: TextStyle(
                            color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(r['date'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
      ],
    );
  }
}
