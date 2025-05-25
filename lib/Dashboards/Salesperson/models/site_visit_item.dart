// Model for a site visit item on the Salesperson dashboard
class SiteVisitItem {
  final String siteId;
  final String name;
  final String avatarPath;
  final String date;
  final bool submitted;

  SiteVisitItem(
      this.siteId, this.name, this.avatarPath, this.date, this.submitted);

  // Optionally, add serialization if needed in the future
  factory SiteVisitItem.fromMap(Map<String, dynamic> map) {
    return SiteVisitItem(
      map['siteId'] as String,
      map['name'] as String,
      map['avatarPath'] as String,
      map['date'] as String,
      map['submitted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'siteId': siteId,
      'name': name,
      'avatarPath': avatarPath,
      'date': date,
      'submitted': submitted,
    };
  }
}
