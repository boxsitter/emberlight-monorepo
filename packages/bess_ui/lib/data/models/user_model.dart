import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/utils/formatters/formatter.dart';

import '../../utils/constants/enums.dart';

/// Model class representing user data
class UserModel implements BessObject{
  @override
  final String? id;
  String firstName;
  String lastName;
  String nickname;
  String email;
  String profilePicture;
  AppRole role;
  BranchRole branchRole;
  @override
  DateTime? createdAt;
  @override
  DateTime? updatedAt;

  /// Constructor for UserModel
  UserModel({
    this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.nickname = '',
    this.profilePicture = '',
    this.role = AppRole.user,
    this.branchRole = BranchRole.counselor,
    this.createdAt,
    this.updatedAt,
  });

  /// Helper methods
  String get displayName => nickname.isNotEmpty ? nickname : firstName;
  String get fullName => '$firstName $lastName';
  @override
  String get formattedDate => BessFormatter.formatDate(createdAt);
  @override
  String get formattedUpdatedAtDate => BessFormatter.formatDate(updatedAt);

  /// Static function to create an empty user model
  static UserModel empty() => UserModel(email: '');

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'email': email,
      'profilePicture': profilePicture,
      'role': role.name.toString(),
      'branchRole': branchRole.name.toString(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory method to create a UserModel from a Firebase document snapshot.
  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        firstName: data.containsKey('firstName') ? data['firstName'] ?? '' : '',
        lastName: data.containsKey('lastName') ? data['lastName'] ?? '' : '',
        nickname: data.containsKey('nickname') ? data['nickname'] ?? '' : '',
        email: data.containsKey('email') ? data['email'] ?? '' : '',
        profilePicture: data.containsKey('profilePicture') ? data['profilePicture'] ?? '' : '',
        role: AppRole.branchAdmin, //TODO: Fix this
        branchRole: BranchRole.director, //TODO: Fix this
        createdAt: data.containsKey('createdAt') ? data['createdAt']?.toDate() ?? DateTime.now() : DateTime.now(),
        updatedAt: data.containsKey('updatedAt') ? data['updatedAt']?.toDate() ?? DateTime.now() : DateTime.now(),
      );
    } else {
      return UserModel.empty();
    }
  }


  @override
  set id(String? id) {
    // TODO: implement id
  }
}

