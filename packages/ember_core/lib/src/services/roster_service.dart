import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/src/validators/collection_validation.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../models/enums/roster_field.dart';
import '../models/interfaces/rosterable.dart';

typedef Roster = Set<Rosterable>;

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
          if (a.age == null) {
            return 1;
          } else if (b.age == null) {
            return -1;
          }
          return a.age!.compareTo(b.age!);
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

  Future<Roster> getRosterFromIds(Set<String> ids) async {
    Set<dynamic> objects = await backend.getObjects(ids);
    if (!CollectionValidation.isValidRoster(objects)) {
      throw CoreInvalidCollectionError('Invalid roster');
    }
    return objects as Roster;
  }

  // TODO: Have this method take roster fields to indicate what fields to return
  List<String> getRowData (Rosterable rosterMember) {
    return [
      rosterMember.fullName,
      rosterMember.preferredName,
      rosterMember.gender,
      rosterMember.age.toString(),
      rosterMember.cabinName ?? 'none',
    ];
  }

  List<List<String>> getTableData(Roster roster) {
    return roster.map((camper) {
      return [
        camper.id,
        camper.fullName,
        camper.preferredName,
        camper.gender,
        camper.age.toString(),
        camper.cabinName ?? 'none',
      ];
    }).toList();
  }


}