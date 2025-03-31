import 'dart:math';

import 'package:bessie/common/utils/validators/bess_id_validation.dart';

class BessIdFunctions {
  static final Random _secureRandom = Random.secure();

  /// Generates a Bess ID in the format:
  /// [idType]-[domain]-[objectType]-[tag]-[5-char random string]
  /// Throws an error if idType or domain is invalid or tag is too short.
  static String generateBessId(String idType, String domain, String objectType, String tag) {
    if (!BessIdValidation.isValidType(idType)) {
      throw ArgumentError('$idType is not a valid idType');
    }
    if (!BessIdValidation.isValidDomain(domain)) {
      throw ArgumentError('$domain is not a valid domain');
    }
    if (tag.length < 3) {
      throw ArgumentError('Tag "$tag" is too short, must be at least 3 characters');
    }
    // Helper: clean input string.
    String clean(String input) {
      return input
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    }
    final cleanType = clean(objectType);
    final cleanTag = clean(tag);
    String randomPart = List.generate(5, (_) => BessIdValidation.validCharacters[_secureRandom.nextInt(BessIdValidation.validCharacters.length)]).join();
    return '$idType-$domain-$cleanType-$cleanTag-$randomPart';
  }

  /// Returns the specified part of a Bess ID.
  /// Index mapping:
  /// 0: idType, 1: domain, 2: objectType, 3: tag, 4: random part.
  static String getIdPart(String id, int index) {
    return id.split('-')[index];
  }

  /// 0: idType, 1: domain, 2: objectType, 3: tag, 4: random part.
  static List<String> getIdParts(String id) {
    return id.split('-');
  }

  static String _editIdType(String id, String newIdType) {
    if (!BessIdValidation.isValidType(newIdType)) {
      throw ArgumentError('Invalid ID type: $newIdType. Must be one of: obj, cmp, ref.');
    }

    List<String> parts = id.split('-');
    parts[0] = newIdType;

    return parts.join('-');
  }

  static String objIdToRef(String id) {
    if (!BessIdValidation.validateIdType(id, 'obj')) {
      throw ArgumentError('objIdToRef error: When creating a reference, you must be referencing and obj id.');
    }
    return _editIdType(id, 'ref');
  }

  static String objIdToCmp(String id) {
    if (!BessIdValidation.validateIdType(id, 'obj')) {
      throw ArgumentError('objIdToCmp error: When creating a reference to a component, you must be referencing and obj id.');
    }
    return _editIdType(id, 'cmp');
  }

  static String refIdToObj(String id) {
    if (BessIdValidation.validateIdType(id, 'obj')) {
     return id;
    }
    return _editIdType(id, 'obj');
  }

  static Set<String> refIdsToObjs(Set<String> ids) {
    Set<String> output = {};
    for (String id in ids) {
      if (BessIdValidation.validateIdType(id, 'obj')) {
        output.add(id);
      } else {
        output.add(_editIdType(id, 'obj'));
      }
    }
    return output;
  }

}