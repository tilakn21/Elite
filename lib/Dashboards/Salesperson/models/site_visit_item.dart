// Model for a site visit item on the Salesperson dashboard
class SiteVisitItem {
  final String siteId;
  final String name;
  final String avatarPath;
  final String date;
  final bool submitted;
  final Map<String, dynamic>? jobJson;
  final Map<String, dynamic>? salespersonJson;
  final Map<String, dynamic>? receptionistJson;

  SiteVisitItem(
    this.siteId,
    this.name,
    this.avatarPath,
    this.date,
    this.submitted, {
    this.jobJson,
    this.salespersonJson,
    this.receptionistJson,
  });

  // Optionally, add serialization if needed in the future
  factory SiteVisitItem.fromMap(Map<String, dynamic> map) {
    return SiteVisitItem(
      map['siteId'] as String,
      map['name'] as String,
      map['avatarPath'] as String,
      map['date'] as String,
      map['submitted'] as bool,
      jobJson: map['jobJson'] as Map<String, dynamic>?,
      salespersonJson: map['salespersonJson'] as Map<String, dynamic>?,
      receptionistJson: map['receptionistJson'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'siteId': siteId,
      'name': name,
      'avatarPath': avatarPath,
      'date': date,
      'submitted': submitted,
      'jobJson': jobJson,
      'salespersonJson': salespersonJson,
      'receptionistJson': receptionistJson,
    };
  }
}
