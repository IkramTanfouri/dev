// lib/screens/manager/manager_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/services/service_locator.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: kBrown,
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: kBrown)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatCard(
                      label: 'Plats',
                      value: '${platService.totalPlats}',
                      icon: Icons.restaurant_menu_outlined),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: 'Commandes',
                      value: '${platService.totalFakeOrders}',
                      icon: Icons.receipt_outlined),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                      label: 'Ventes',
                      value: '${platService.totalFakeSales.toStringAsFixed(1)} DA',
                      icon: Icons.payments_outlined),
                  const SizedBox(width: 12),
                  _StatCard(
                      label: 'Top plat',
                      value: platService.mostOrderedPlat,
                      icon: Icons.star_outline),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Commandes par heure',
                  style: TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kBrown)),
              const SizedBox(height: 16),
              _BarChart(data: platService.getOrdersPerHour()),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kInputBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: kBrown, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kBrown)),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 12,
                        color: kBrown.withOpacity(0.65))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<int, int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text('Aucune commande aujourd\'hui',
            style: TextStyle(
                fontFamily: 'LeagueSpartan', color: kGrey)),
      );
    }
    final hours = data.keys.toList()..sort();
    final bars = hours.map((h) {
      return BarChartGroupData(
        x: h,
        barRods: [
          BarChartRodData(
            toY: (data[h] ?? 0).toDouble(),
            color: kBrown,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}h',
                  style: const TextStyle(
                      fontFamily: 'LeagueSpartan',
                      fontSize: 11,
                      color: kBrown),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
