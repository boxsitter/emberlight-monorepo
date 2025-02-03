import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/season.dart';

class Branch extends BessObject{
  String name;
  Map<String, Season> seasons = {};

  Branch({
    required BessObject dataParent,
    required this.name
  }) : super('Branch-$name', dataParent);

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