import 'package:bessie/data/abstract/bess_object.dart';
import 'package:bessie/data/models/season.dart';

class Branch extends BessObject{
  String name;
  final Map<String, Season> seasons;

  Branch({
    required this.name,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : seasons = {},
        super(
        idTitle: 'branch-$name',
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  String bessToString() {
    return 'Branch: $name, Seasons: ${seasons.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'name': name,
      'seasons': seasons.map((key, season) => MapEntry(key, season.toJson())),
    });
    return json;
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    final branch = Branch(
      name: json['name'] as String,
      id: json['id'] as String,
      createdAt: DateTime.tryParse(json['createdAt'] as String),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String),
    );
    if (json.containsKey('seasons')) {
      final seasonsJson = json['seasons'] as Map<String, dynamic>;
      seasonsJson.forEach((key, seasonJson) {
        branch.seasons[key] =
            Season.fromJson(seasonJson as Map<String, dynamic>);
      });
    }
    return branch;
  }
}