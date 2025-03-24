import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Season extends BessObject {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> sessions;

  Season({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.sessions = const {},
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
    idTitle: 'season-$name',
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
      'sessions': sessions.toList(),
    });
    return json;
  }

  factory Season.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final season = Season(
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      sessions: (json['sessions'] as List?)?.cast<String>().toSet() ?? <String>{},
    );
    season.overwriteBessObjectFromJson(json, clone);
    return season;
  }
}
