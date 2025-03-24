import 'package:uuid/uuid.dart';

class BessIdFunctions {
  static String getBessId(String idTitle) {
    var uuid = const Uuid();
    return '$idTitle-${uuid.v4()}'
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w-]'), '')
        .toLowerCase();
  }

  static String getIdPrefix(String id) {
    return id.contains('-') ? id.split('-').first : id;
  }
}