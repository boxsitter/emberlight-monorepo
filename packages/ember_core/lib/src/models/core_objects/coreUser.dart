import 'package:ember_core/ember_core_models.dart';

import '../../../ember_core_services.dart';

enum Role {
  root,
  director,
  admin,
  counselor,
}

class CoreUser extends CoreObject {
  String firstName;
  String? preferredName;
  String lastName;
  String note;
  BranchId branchPar;
  OrganizationId organizationRef;
  Role role;
  bool active;
  String? deactivationReason;


  CoreUser({
    required this.firstName,
    required this.lastName,
    this.preferredName,
    this.note = '',
    required this.branchPar,
    required this.organizationRef,
    required this.role,
    this.active = true,
    this.deactivationReason,
    super.id,
    super.createdAt,
    super.updatedAt,
  }) : super(
      domain: 'brn',
      type: 'core_user',
      idTag: '${firstName}_${lastName[0]}'
  );

  /// returns preferred name if set, first name if not
  String get name => preferredName != null ? preferredName! : firstName;
  String get fullName => '$name $lastName';
  String get lastInitial => lastName[0];

  @override
  String coreToString() {
    // TODO: implement coreToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'firstName': firstName,
      'lastName': lastName,
      'preferredName': preferredName,
      'note': note,
      'branchPar': branchPar,
      'organizationRef': organizationRef,
      'role': role.name,
      'active': active,
      'deactivationReason': deactivationReason,
    });
    return json;
  }

  factory CoreUser.fromJson(Map<String, dynamic> json) {
    CoreUser user = CoreUser(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      preferredName: json['preferredName'] ?? '',
      note: json['note'] ?? '',
      branchPar: json['branchPar'] as String,
      organizationRef: json['organizationRef'] as String,
      role: Role.values.byName(json['role'] as String),
      active: json['active'] as bool,
      deactivationReason: json['deactivationReason'] as String,
    );
    user.overwriteCoreObjectFromJson(json);
    return user;
  }

  @override
  void purgeRef(String id) {

  }
}
