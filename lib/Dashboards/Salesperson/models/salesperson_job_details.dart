// Model for Salesperson job details (for details screen)
class SalespersonJobDetails {
  final String customer;
  final String jobNo;
  final String date;
  final String typeOfSign;
  final String material;
  final String toolsNails;
  final String timeForProduction;
  final String timeForFitting;
  final String extraDetails;
  final String signMeasurements;
  final String windowVinylMeasurements;
  final String stickSide;

  SalespersonJobDetails({
    required this.customer,
    required this.jobNo,
    required this.date,
    required this.typeOfSign,
    required this.material,
    required this.toolsNails,
    required this.timeForProduction,
    required this.timeForFitting,
    required this.extraDetails,
    required this.signMeasurements,
    required this.windowVinylMeasurements,
    required this.stickSide,
  });

  factory SalespersonJobDetails.fromMap(Map<String, dynamic> map) {
    return SalespersonJobDetails(
      customer: map['customer'] as String,
      jobNo: map['jobNo'] as String,
      date: map['date'] as String,
      typeOfSign: map['typeOfSign'] as String,
      material: map['material'] as String,
      toolsNails: map['toolsNails'] as String,
      timeForProduction: map['timeForProduction'] as String,
      timeForFitting: map['timeForFitting'] as String,
      extraDetails: map['extraDetails'] as String,
      signMeasurements: map['signMeasurements'] as String,
      windowVinylMeasurements: map['windowVinylMeasurements'] as String,
      stickSide: map['stickSide'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer': customer,
      'jobNo': jobNo,
      'date': date,
      'typeOfSign': typeOfSign,
      'material': material,
      'toolsNails': toolsNails,
      'timeForProduction': timeForProduction,
      'timeForFitting': timeForFitting,
      'extraDetails': extraDetails,
      'signMeasurements': signMeasurements,
      'windowVinylMeasurements': windowVinylMeasurements,
      'stickSide': stickSide,
    };
  }
}
