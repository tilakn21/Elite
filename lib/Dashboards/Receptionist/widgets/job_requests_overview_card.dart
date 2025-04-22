import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class JobRequestsOverviewCard extends StatelessWidget {
  const JobRequestsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      color: Colors.white,
      child: Container(
        // constraints: const BoxConstraints.expand(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Job Requests Overview', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1B2330))),
                    Text('Month', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF8A8D9F), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 450,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
                              return Padding(
                                padding: EdgeInsets.only(top: 6.0),
                                child: Text(months[value.toInt() % 12], style: TextStyle(fontSize: 13, color: Color(0xFF8A8D9F))),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _barData,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<BarChartGroupData> _barData = List.generate(12, (i) {
  final heights = [100, 120, 140, 210, 300, 250, 200, 100, 350, 400, 420, 430];
  return BarChartGroupData(
    x: i,
    barRods: [
      BarChartRodData(
        toY: heights[i].toDouble(),
        color: const Color(0xFF4A6CF7),
        width: 18,
        borderRadius: BorderRadius.circular(7),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 450,
          color: Color(0xFFEDF0F9),
        ),
      ),
    ],
  );
});
