// Model for sales data point (for sales performance chart)
class SalesData {
  final double x;
  final double y;

  SalesData(this.x, this.y);

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      json['x'] as double,
      json['y'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
