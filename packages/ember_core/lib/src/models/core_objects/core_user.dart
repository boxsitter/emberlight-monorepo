import 'package:ember_core/ember_core_models.dart';

import '../../../ember_core_services.dart';
import '../interfaces/elevated.dart';

class CoreUser extends CoreObject implements Elevated {
  String? firebaseUid;
  String firstName;
  String? preferredName;
  String lastName;
  String note;
  // TODO: Fix these and make sure it is handled in the reference tracker
  // TODO: Don't track these references in a single season where they were created
  // BranchId branchRef;
  // OrganizationId organizationRef;
  Role role;
  bool active;
  String? deactivationReason;


  CoreUser({
    required this.firebaseUid,
    required this.firstName,
    required this.lastName,
    this.preferredName,
    this.note = '',
    // required this.branchRef,
    // required this.organizationRef,
    required this.role,
    this.active = true,
    this.deactivationReason,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
      domain: 'rot',
      type: 'core_user',
      idTag: '${firstName}_${lastName[0]}'
  );

  /// returns preferred name if set, first name if not
  String get name => preferredName != null ? preferredName! : firstName;
  String get fullName => '$name $lastName';
  String get lastInitial => lastName[0];
  String get firstInitial => name[0];

  @override
  String coreToString() {
    // TODO: implement coreToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'firebaseUid': firebaseUid,
      'firstName': firstName,
      'lastName': lastName,
      'preferredName': preferredName,
      'note': note,
      // 'branchRef': branchRef,
      // 'organizationRef': organizationRef,
      'role': role.name,
      'active': active,
      'deactivationReason': deactivationReason,
    });
    return json;
  }

  factory CoreUser.fromJson(Map<String, dynamic> json) {
    CoreUser user = CoreUser(
      firebaseUid: json['firebaseUid'] as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      preferredName: json['preferredName'],
      note: (json['note'] ?? '') as String,
      // branchRef: json['branchRef'] as String,
      // organizationRef: json['organizationRef'] as String,
      role: Role.values.byName(json['role'] as String),
      active: json['active'] as bool,
      deactivationReason: (json['deactivationReason'] ?? '') as String,
    );
    user.overwriteCoreObjectFromJson(json);
    return user;
  }

  @override
  void purgeRef(String id) {

  }
}
