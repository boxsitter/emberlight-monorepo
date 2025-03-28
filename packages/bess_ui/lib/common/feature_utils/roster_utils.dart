import 'package:bessie/common/feature_utils/pdf_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import '../../../../data/models/camper.dart';
import '../../data/models/session.dart';
import '../../pages/console/controller/console_controller.dart';

class RosterUtils {
  /// Returns the first Camper with a matching full name, or null if not found.
  static Camper? getCamperByName(Set<Camper> campers, String fullName) {
    // Using firstWhereOrNull from package:collection
    return campers.firstWhereOrNull((camper) => camper.fullName == fullName);
  }

  /// Removes the camper with the given [id] from the set.
  static void removeCamperById(Set<Camper> campers, String id) {
    campers.removeWhere((camper) => camper.id == id);
  }

  /// Logs the campers to the console.
  static void logCampers(Set<Camper> campers) {
    final rosterString = campers.map((camper) => camper.bessToString()).join('\n');
  }

  /// Exports a PDF of the campers.
  /// Note: This assumes you have or create a PdfUtils.campersToPdf that accepts a Set<Camper>.
  static void exportPdf(Set<Camper> campers, Session currentSession) {
    // Convert the set of campers to a PDF document.
    final pdf = PdfUtils.campersToPdf(campers);
    final formattedSessionName = currentSession.name.replaceAll(' ', '_').toLowerCase();
    // Since we no longer have roster.formattedUpdatedAt, we'll use the current timestamp.
    final formattedTimestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w_]'), '-')
        .toLowerCase();
    PdfUtils.savePdfLocally(pdf, 'master_roster_${formattedSessionName}_$formattedTimestamp.pdf');
  }
}