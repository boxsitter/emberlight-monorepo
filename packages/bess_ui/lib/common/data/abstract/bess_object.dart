import 'package:bessie/common/utils/helpers/helper_functions.dart';

import '../../utils/formatters/formatter.dart';

abstract class BessObject {
  final String id;
  final DateTime createdAt;
  DateTime updatedAt;
  final String idTitle;

  final BessObject? dataParent; // the model this object is a child of in the Bessie Data Structure
  bool isUpdating = false;

  // Default constructor that sets id
  BessObject(this.idTitle, this.dataParent) :
    id = BessHelperFunctions.getBessId(idTitle),
    createdAt = DateTime.now(),
    updatedAt = DateTime.now();

  // Concrete implementation
  String get formattedCreatedAt => BessFormatter.formatDate(createdAt);
  String get formattedUpdatedAt => BessFormatter.formatDate(createdAt);

  // Abstract methods to enforce implementation in subclasses
  // Explicitly mark toString as abstract
  String bessToString();
  Map<String, dynamic> toJson();

  /// Helper method for converting superclass properties to JSON
  Map<String, dynamic> toJsonSuper() {
    return {
      'id': id,
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
    dataParent?.updateTimestamp();

    Future.delayed(const Duration(milliseconds: 50), () {
      isUpdating = false;
    });
  }
}
