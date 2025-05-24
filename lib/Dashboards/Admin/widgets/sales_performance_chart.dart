import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesPerformanceChart extends StatelessWidget {
  final List<FlSpot> data;
  const SalesPerformanceChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232B3E),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        return Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(months[value.toInt() % months.length], style: TextStyle(color: Colors.white, fontSize: 12)),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 8,
                minY: 0,
                maxY: 700,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Sales performance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Revenue', style: TextStyle(color: Color(0xFFB0B3C7), fontWeight: FontWeight.w400, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
              SizedBox(width: 6),
              Text('just updated', style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
