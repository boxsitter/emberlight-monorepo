import '../abstract/bess_object.dart';
import 'cabin.dart';

class Camper extends BessObject {
  String firstName;
  String preferredName;
  String lastName;
  String gender;
  int age;
  Cabin? cabin;

  Camper({
    this.firstName = '',
    this.lastName = '',
    this.preferredName = '',
    this.gender = '',
    this.age = 0,
    this.cabin,
  }) : super('camper-$lastName-$firstName');

  /// returns preferred name if set, first name if not
  String get name => preferredName.isNotEmpty ? preferredName : firstName;
  String get fullName => '$name $lastName';

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'firstName': firstName,
      'lastName': lastName,
      'preferredName': preferredName,
      'age': age,
    });
    return json;
  }

  @override
  String bessToString() {
    String idField = toStringSuper();
    String nameField = fullName;
    String ageField = 'Age: $age';
    String cabinField = 'Cabin: ${cabin?.name ?? "none"}';

    return '$idField $nameField, $ageField, $cabinField';
  }

  void addToCabin(Cabin cabin) {
    cabin.addCamper(this);
  }

  void removeFromCabin(Cabin cabin) {
    cabin.removeCamper(this);
  }

}