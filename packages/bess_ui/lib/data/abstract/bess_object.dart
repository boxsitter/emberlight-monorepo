
abstract class BessObject {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  String get formattedDate;
  String get formattedUpdatedAtDate;

  @override
  String toString();
  Map<String, dynamic> toJson();
}