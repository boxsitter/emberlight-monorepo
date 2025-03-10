import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/season.dart';

class Branch extends BessObject{
  String name;

  Branch({
    required this.name
  }) : super(idTitle: 'branch-$name');

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