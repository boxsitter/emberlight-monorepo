import '../../utils/constants/enums.dart';
import '../../utils/formatters/formatter.dart';
import '../abstract/bess_object.dart';

/// Model class representing user data
class User extends BessObject {
  String firstName;
  String lastName;
  String nickname;
  String email;
  String profilePicture;
  AppRole role;
  BranchRole branchRole;

  /// Constructor for UserModel
  User({
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.nickname = '',
    this.profilePicture = '',
    this.role = AppRole.user,
    this.branchRole = BranchRole.counselor,
  }) : super(email);

  /// Helper methods
  String get displayName => nickname.isNotEmpty ? nickname : firstName;

  String get fullName => '$firstName $lastName';

  @override
  String get formattedDate => BessFormatter.formatDate(createdAt);

  /// Static function to create an empty user model
  static User empty() => User(email: '');

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
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  // /// Factory method to create a UserModel from a Firebase document snapshot.
  // factory User.fromSnapshot(
  //     DocumentSnapshot<Map<String, dynamic>> document) {
  //   if (document.data() != null) {
  //     final data = document.data()!;
  //     return User(
  //       id: document.id,
  //       firstName: data.containsKey('firstName') ? data['firstName'] ?? '' : '',
  //       lastName: data.containsKey('lastName') ? data['lastName'] ?? '' : '',
  //       nickname: data.containsKey('nickname') ? data['nickname'] ?? '' : '',
  //       email: data.containsKey('email') ? data['email'] ?? '' : '',
  //       profilePicture: data.containsKey('profilePicture')
  //           ? data['profilePicture'] ?? ''
  //           : '',
  //       role: AppRole.branchAdmin,
  //       //TODO: Fix this
  //       branchRole: BranchRole.director,
  //       //TODO: Fix this
  //       createdAt: data.containsKey('createdAt')
  //           ? data['createdAt']?.toDate() ?? DateTime.now()
  //           : DateTime.now(),
  //       updatedAt: data.containsKey('updatedAt')
  //           ? data['updatedAt']?.toDate() ?? DateTime.now()
  //           : DateTime.now(),
  //     );
  //   } else {
  //     return User.empty();
  //   }
  // }
}
