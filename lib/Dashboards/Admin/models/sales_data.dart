import 'package:fl_chart/fl_chart.dart';

class SalesData {
  final List<FlSpot> data;
  final double maxY;
  final double minY;
  final int dataPoints;

  const SalesData({
    required this.data,
    required this.maxY,
    required this.minY,
    required this.dataPoints,
  });

  factory SalesData.fromPoints(List<FlSpot> points) {
    if (points.isEmpty) {
      return const SalesData(
        data: [],
        maxY: 0,
        minY: 0,
        dataPoints: 0,
      );
    }

    double max = points[0].y;
    double min = points[0].y;

    for (var spot in points) {
      if (spot.y > max) max = spot.y;
      if (spot.y < min) min = spot.y;
    }

    return SalesData(
      data: points,
      maxY: max,
      minY: min,
      dataPoints: points.length,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((spot) => {'x': spot.x, 'y': spot.y}).toList(),
    'maxY': maxY,
    'minY': minY,
    'dataPoints': dataPoints,
  };

  factory SalesData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataPoints = json['data'] as List;
    return SalesData(
      data: dataPoints.map((point) => FlSpot(
        (point as Map<String, dynamic>)['x'] as double,
        point['y'] as double,
      )).toList(),
      maxY: json['maxY'] as double,
      minY: json['minY'] as double,
      dataPoints: json['dataPoints'] as int,
    );
  }
}
