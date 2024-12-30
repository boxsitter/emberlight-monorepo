import 'package:bessie/common/data/abstract/bess_object.dart';
import 'package:bessie/common/data/models/season.dart';

class Branch extends BessObject{
  String name;
  Map<String, Season> seasons;

  Branch({required this.name}) : seasons = {}, super('Branch-$name');

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

  /// Add a Season to the map
  void addSeason(Season season) {
    seasons[season.id] = season;
  }

  /// Retrieve a season by id
  Season? getSeasonById(String id) {
    return seasons[id];
  }
}