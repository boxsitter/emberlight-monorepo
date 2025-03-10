import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/session.dart';

class Season extends BessObject{
  String name;

  Season({
    required this.name,
  }) : super(idTitle: 'season-$name');

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