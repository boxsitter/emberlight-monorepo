import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/src/models/interfaces/time_interval.dart';

import '../../interfaces/elevated.dart';

typedef DependentId = String;
typedef PrincipalId = String;

class Session extends CoreObject implements Domain, Elevated, TimeInterval{
  final String name;
  @override
  final DateTime start;
  @override
  final DateTime end;
  Map<String, Set<String>> refTracker;
  Map<PrincipalId, Set<DependentId>> principalDependentLinkTracker; //TODO: On init, check the integrity of all principals. If one is missing, call delete on all its dependents and purge references to it

  Session({
    required this.name,
    required this.start,
    required this.end,
    Map<String, Set<String>>? refTracker,
    Map<String, Set<String>>? principalDependentLinkTracker,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : refTracker = refTracker ?? {},
        principalDependentLinkTracker = principalDependentLinkTracker ?? {},
        super(
          domain: 'sea',
          type: 'session',
          idTag: name,
        );

  @override
  String coreToString() {
    return 'Session: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'start': start,
      'end': end,
      'refTracker': refTracker.map((key, value) => MapEntry(key, value.toList())),
      'principalDependentLinkTracker': principalDependentLinkTracker.map((key, value) => MapEntry(key, value.toList())),
    });
    return json;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final session = Session(
      name: json['name'] as String,
      start: json['start'] as DateTime,
      end: json['end'] as DateTime,
      refTracker: (json['refTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
      principalDependentLinkTracker: (json['principalDependentLinkTracker'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, Set<String>.from(value ?? [])),) ?? {},
    );
    session.overwriteCoreObjectFromJson(json);
    return session;
  }

  @override
  void purgeRef(String id) {
    print('Purging $id from ${this.id}');
    refTracker.remove(id);

    for (Set<String> set in refTracker.values) {
      set.remove(id);
      if (set.isEmpty) {
        refTracker.removeWhere((key, value) => value == set);
      }
    }

    principalDependentLinkTracker.remove(id);

    for (Set<String> set in principalDependentLinkTracker.values) {
      set.remove(id);
      if (set.isEmpty) {
        principalDependentLinkTracker.removeWhere((key, value) => value == set);
      }
    }
  }
}
