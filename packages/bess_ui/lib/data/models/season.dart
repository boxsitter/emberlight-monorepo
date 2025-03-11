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
      'startDate': startDate,
      'endDate': endDate,
    });
    return json;
  }

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      id: json['id'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}