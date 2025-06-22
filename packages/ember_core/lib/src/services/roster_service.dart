import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/src/validators/collection_validation.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../../ember_core_models.dart';
import '../models/interfaces/rosterable.dart';
import '../models/roster_field.dart';

typedef Roster = List<Rosterable>;

class RosterService extends GetxService {
  static CoreBackend backend = BackendManager.instance;

  static Type getMemberType(Roster roster) {
    if (!CollectionValidation.isValidRoster(roster)) {
      throw CoreInvalidCollectionError('Invalid roster');
    }

    return roster.first.runtimeType;
  }

  Future<List<T>> sort<T extends Rosterable>(Roster roster, RosterField fieldToSortBy, [bool? descending,]) async {
    List<T> list = roster.toList().cast<T>();
    bool isDescending = descending ?? false;

    Comparator<T> comparator;

    switch (fieldToSortBy) {
      case RosterField.firstName:
        comparator = (a, b) =>
            a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
        break;
      case RosterField.lastName:
        comparator = (a, b) =>
            a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
        break;
      case RosterField.gender:
        comparator = (a, b) =>
            a.gender.toLowerCase().compareTo(b.gender.toLowerCase());
        break;
      case RosterField.age:
        comparator = (a, b) {
          return a.age.compareTo(b.age);
        };
        break;
      default:
        Debug.logWarning('Unsuccessful roster sort');
        return Future.value(list);
    }

    list.sort((a, b) {
      final comparisonResult = comparator(a, b);
      return isDescending ? -comparisonResult : comparisonResult;
    });

    return Future.value(list);
  }

  List<String> getRowData(Roster roster, int rowIndex, List<RosterField> fields) {
    Rosterable member = roster[rowIndex];
    List<String> output = [];
    for (RosterField field in fields) {
      output.add(member.getFieldAsString(field));
    }
    return output;
  }

}