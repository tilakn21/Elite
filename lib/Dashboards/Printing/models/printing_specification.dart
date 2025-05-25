enum PaperType {
  gloss,
  matte,
  semiGloss,
  uncoated,
  vinyl,
  canvas,
  fabric,
  other,
}

enum PrintQuality {
  draft,
  standard,
  high,
  ultra,
}

enum PaperSize {
  a0,
  a1,
  a2,
  a3,
  a4,
  a5,
  letter,
  legal,
  tabloid,
  custom,
}

class PrintingSpecification {
  final String id;
  final PaperType paperType;
  final PaperSize paperSize;
  final double? customWidth; // in inches, required if paperSize is custom
  final double? customHeight; // in inches, required if paperSize is custom
  final bool isDoubleSided;
  final bool isColorPrint;
  final PrintQuality quality;
  final int dpi;
  final Map<String, dynamic>? colorSettings; // Custom color profile settings
  final Map<String, dynamic>? finishingOptions; // Lamination, binding, etc.
  final Map<String, dynamic>? additionalSettings;
  final String? notes;

  const PrintingSpecification({
    required this.id,
    required this.paperType,
    required this.paperSize,
    this.customWidth,
    this.customHeight,
    required this.isDoubleSided,
    required this.isColorPrint,
    required this.quality,
    required this.dpi,
    this.colorSettings,
    this.finishingOptions,
    this.additionalSettings,
    this.notes,
  }) : assert(
            paperSize != PaperSize.custom ||
                (customWidth != null && customHeight != null),
            'Custom width and height are required when paperSize is custom');

  Map<String, dynamic> toJson() => {
        'id': id,
        'paperType': paperType.name,
        'paperSize': paperSize.name,
        'customWidth': customWidth,
        'customHeight': customHeight,
        'isDoubleSided': isDoubleSided,
        'isColorPrint': isColorPrint,
        'quality': quality.name,
        'dpi': dpi,
        'colorSettings': colorSettings,
        'finishingOptions': finishingOptions,
        'additionalSettings': additionalSettings,
        'notes': notes,
      };

  factory PrintingSpecification.fromJson(Map<String, dynamic> json) =>
      PrintingSpecification(
        id: json['id'] as String,
        paperType: PaperType.values.firstWhere(
          (e) => e.name == json['paperType'] as String,
          orElse: () => PaperType.other,
        ),
        paperSize: PaperSize.values.firstWhere(
          (e) => e.name == json['paperSize'] as String,
          orElse: () => PaperSize.a4,
        ),
        customWidth: json['customWidth'] != null
            ? (json['customWidth'] as num).toDouble()
            : null,
        customHeight: json['customHeight'] != null
            ? (json['customHeight'] as num).toDouble()
            : null,
        isDoubleSided: json['isDoubleSided'] as bool,
        isColorPrint: json['isColorPrint'] as bool,
        quality: PrintQuality.values.firstWhere(
          (e) => e.name == json['quality'] as String,
          orElse: () => PrintQuality.standard,
        ),
        dpi: json['dpi'] as int,
        colorSettings: json['colorSettings'] as Map<String, dynamic>?,
        finishingOptions: json['finishingOptions'] as Map<String, dynamic>?,
        additionalSettings: json['additionalSettings'] as Map<String, dynamic>?,
        notes: json['notes'] as String?,
      );
}
