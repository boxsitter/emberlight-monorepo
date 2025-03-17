import 'package:bessie/common/utils/helpers/helper_functions.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Season extends BessObject {
  String name;
  DateTime startDate;
  DateTime endDate;

  Season({
    required this.name,
    required this.startDate,
    required this.endDate,
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
    });
    return json;
  }

  factory Season.fromJson(Map<String, dynamic> json, [bool clone = false]) {
    final season = Season(
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
    );
    season.overwriteBessObjectFromJson(json, clone);
    return season;
  }
}
