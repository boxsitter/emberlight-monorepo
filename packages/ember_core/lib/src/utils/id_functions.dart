import 'dart:math';

import 'package:ember_core/ember_core_validators.dart';

class IdFunctions {
  static final Random _secureRandom = Random.secure();

  static String clean(String input) {
    return input
        .toLowerCase() // PUT THIS BACK
        .replaceAll(' ', '_')
    // Revert regex to only allow lowercase/numbers/_
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }


  /// Generates a Core ID in the format:
  /// [domain]-[objectType]-[tag]-[5-char random string]
  /// Throws an error if idType or domain is invalid or tag is too short.
  static String generateCoreId(String domain, String objectType, String tag) {
    if (!CoreIdValidation.isValidDomain(domain)) {
      throw ArgumentError('$domain is not a valid domain');
    }
    // if (tag.length < 3) {
    //   throw ArgumentError('Tag "$tag" is too short, must be at least 3 characters');
    // }
    final cleanType = clean(objectType);
    final cleanTag = clean(tag);
    String randomPart = List.generate(6, (_) => CoreIdValidation.validCharacters[_secureRandom.nextInt(CoreIdValidation.validCharacters.length)]).join();
    return '$domain-$cleanType-$cleanTag-$randomPart';
  }

  static String generateSimpleId(String tag) {
    final cleanTag = clean(tag);
    String randomPart = List.generate(6, (_) => CoreIdValidation.validCharacters[_secureRandom.nextInt(CoreIdValidation.validCharacters.length)]).join();
    return '$cleanTag-$randomPart';
  }

  /// Returns the specified part of a Core ID.
  /// Index mapping:
  /// 0: domain, 1: objectType/collection name, 2: tag, 3: random part.
  static String getIdPart(String id, int index) {
    return id.split('-')[index];
  }

  /// 0: domain, 1: objectType/collection name, 2: tag, 3: random part.
  static List<String> getIdParts(String id) {
    return id.split('-');
  }

}