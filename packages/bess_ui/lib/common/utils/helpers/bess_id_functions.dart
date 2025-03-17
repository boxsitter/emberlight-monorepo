import 'package:uuid/uuid.dart';

class BessIdFunctions {
  static String getBessId(String idTitle) {
    var uuid = const Uuid();
    return '$idTitle-${uuid.v4()}'
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w-]'), '')
        .toLowerCase();
  }

  static String getTypeFromId(String input) {
    final dashIndex = input.indexOf('-');
    if (dashIndex == -1) return input; // No dash found, return the whole string.
    return input.substring(0, dashIndex).replaceAll('_', ' ');
  }

  static String extractIdSections(String input, int start, int end, bool titleCase) {
    // Split the input string on dashes.
    List<String> parts = input.split('-');

    // Ensure start is within bounds.
    if (start < 0) start = 0;
    if (start >= parts.length) return '';

    // If the requested end is beyond available parts, adjust it.
    if (end >= parts.length) {
      end = parts.length - 1;
    }

    // Extract the desired range (end is inclusive, so use end+1 for sublist).
    List<String> selected = parts.sublist(start, end + 1);

    // If titleCase is true, capitalize the first letter of each substring.
    if (titleCase) {
      selected = selected.map((s) {
        if (s.isEmpty) return s;
        return s[0].toUpperCase() + s.substring(1);
      }).toList();
    }

    // Join the substrings with spaces (replacing the dashes).
    return selected.join(' ').replaceAll('_', ' ');
  }
  static String cabinNameFromId(String? cabinId, String returnIfNull) {
    if (cabinId == null) {
      return returnIfNull;
    } else {
      return extractIdSections(cabinId, 1, 1, true);
    }
  }

}