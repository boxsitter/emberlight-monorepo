import '../abstract/bess_object.dart';

class Cabin extends BessObject {
  String name;
  int capacity;

  Cabin({
    this.name = '',
    this.capacity = 0,
  }) : super('Cabin-$name');

  @override
  String bessToString() {
    // TODO: implement bessToString
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }


}