import 'package:bessie/common/utils/helpers/helper_functions.dart';

import '../../utils/formatters/formatter.dart';

abstract class BessObject {
  final String id;
  final DateTime createdAt;
  DateTime updatedAt;
  final String idTitle;

  // Default constructor that sets id
  BessObject(this.idTitle)
      : id = BessHelperFunctions.getBessId(idTitle),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  void updateUpdatedAt() {
    updatedAt = DateTime.now();
  }

  // Concrete implementation
  String get formattedDate => BessFormatter.formatDate(createdAt);
  String get formattedUpdatedAtDate => BessFormatter.formatDate(updatedAt);

  // Abstract methods to enforce implementation in subclasses
  // Explicitly mark toString as abstract
  String bessToString();
  Map<String, dynamic> toJson();

  /// Helper method for converting superclass properties to JSON
  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper method for converting superclass properties to String
  String toStringSuper() {
    return '[$id]';
  }
}
