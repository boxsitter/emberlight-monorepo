import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/season_info.dart';

class BranchInfo extends BessObject{
  String name;
  Map<String, SeasonInfo> seasons = {};

  BranchInfo({
    required this.name
  }) : super(idTitle: 'Branch-$name');

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