import '../../../../ember_core.dart';

class AMABlock extends CoreObject implements ScheduleBlock, Titled, RosterField {
  @override
  final String title;
  @override
  final bool isTemplate;
  @override
  DateTime start;
  @override
  DateTime end;
  final Set<String> activityDependentCmps;
  bool isSkillsRec;

  AMABlock({
    required this.title,
    required this.isTemplate,
    required this.start,
    required this.end,
    Set<String>? activityDependentCmps,
    required this.isSkillsRec,
    super.id,
    super.createdAt,
    super.updatedAt,
  })  : activityDependentCmps = activityDependentCmps ?? {},
        super(
          domain: 'ses',
          type: 'ama_block',
          idTag: title,
        );

  @override
  String get displayTitle => isSkillsRec == false ? '${DateTimeHelpers.dateTimeToWeekdayString(start, true)} - $title' : title;

  @override
  String coreToString() {
    return 'AMABlock: $title, Activities: ${activityDependentCmps.length}';
  }

  @override
  Map<String, dynamic> toJson() {
    final json = toJsonSuper();
    json.addAll({
      'title': title,
      'isTemplate': isTemplate,
      'start': start,
      'end': end,
      'activityDependentCmps': activityDependentCmps.toList(),
      'isSkillsRec': isSkillsRec,
    });
    return json;
  }

  factory AMABlock.fromJson(Map<String, dynamic> json) {
    final block = AMABlock(
      title: json['title'] as String,
      isTemplate: json['isTemplate'],
      start: json['start'] as DateTime,
      end: json['end'] as DateTime,
      activityDependentCmps: (json['activityDependentCmps'] as List?)?.cast<String>().toSet() ?? <String>{},
      isSkillsRec: json['isSkillsRec'] as bool,
    );
    block.overwriteCoreObjectFromJson(json);
    return block;
  }

  @override
  void purgeRef(String id) {
    Debug.logInfo('Purging $id from ${this.id}');
    // TODO: implement purgeRef
  }

  @override
  String? get csvHeader => null;
  @override
  String? get csvHeaderAlt => null;
  @override
  String? get dataId => id;

  @override
  double get defaultWidth => RosterField.widthXl;
  @override
  String get name => title;
  @override
  // TODO: implement required
  bool get required => false;
  @override
  bool get allowGrouping => true;

}
