

import 'package:ember_core/ember_core_models.dart';

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
  void purgeRef(String id) {
    print('unnecessary purge');
    return;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
    });
    return json;
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    final season = Season(
      name: json['name'] ?? '',
      // Just cast the values as DateTime now:
      startDate: json['startDate'] as DateTime,
      endDate: json['endDate'] as DateTime,
    );
    season.overwriteBessObjectFromJson(json);
    return season;
  }

}
