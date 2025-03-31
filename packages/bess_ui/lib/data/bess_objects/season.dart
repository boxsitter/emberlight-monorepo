import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Season extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  Season({
    required this.name,
    required this.startDate,
    required this.endDate,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : super(
          domain: 'brn',
          type: 'season',
          idTag: name,
        );

  @override
  String bessToString() {
    return 'Season: $name, Start: $startDate, End: $endDate';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    });
    return json;
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    final season = Season(
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
    );
    season.overwriteBessObjectFromJson(json);
    return season;
  }
}
