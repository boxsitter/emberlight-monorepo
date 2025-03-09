import 'package:bessie/common/utils/helpers/helper_functions.dart';

import '../../common/utils/formatters/formatter.dart';

abstract class BessObject {
  final String id;
  final DateTime createdAt;
  DateTime updatedAt;
  final String idTitle;
  bool isUpdating = false;

  // Default constructor for new objects
  BessObject({
    required this.idTitle,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? BessHelperFunctions.getBessId(idTitle),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Concrete implementation
  String get formattedCreatedAt => BessFormatter.formatDate(createdAt);
  String get formattedUpdatedAt => BessFormatter.formatDate(updatedAt);

  // Abstract methods to enforce implementation in subclasses
  // Explicitly mark toString as abstract
  String bessToString();
  Map<String, dynamic> toJson();

  /// Helper method for converting superclass properties to JSON
  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
      'idTitle': idTitle,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper method for converting superclass properties to String
  String toStringSuper() {
    return '[$id]';
  }

  void updateTimestamp() {
    if (isUpdating) {
      return;
    }

    isUpdating = true;
    updatedAt = DateTime.now();

    Future.delayed(const Duration(milliseconds: 30), () {
      isUpdating = false;
    });
  }
}
