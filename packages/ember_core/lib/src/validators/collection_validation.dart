import 'package:ember_core/src/models/interfaces/rosterable.dart';

class CollectionValidation {

  static bool isValidRoster(Set<dynamic> collection) {
    // No duplicates allows (using set)
    // All members must be rosterable
    for (final element in collection) {
      if (element is! Rosterable) {
        return false;
      }
    }
    final Set<Rosterable> rosterableCollection = collection as Set<Rosterable>;

    // All members must share the same type
    Type? type;
    for (final element in collection) {
      if (type == null) {
        type = element.runtimeType;
      } else if (element.runtimeType != type) {
        return false;
      }
    }
    return true;
  }
}