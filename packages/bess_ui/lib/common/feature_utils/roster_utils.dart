import 'package:bessie/common/feature_utils/pdf_utils.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';
import '../../data/models/session.dart';
import '../../pages/console/controller/console_controller.dart';

class RosterUtils {
  static Camper? getCamperByNameFromRoster(Roster roster, String fullName) {
    for (Camper camper in roster.campers.values) {
      if (camper.fullName == fullName) {
        return camper;
      }
    }
    return null; // TODO: Error checking, throw camper not found
  }

  static void removeCamperById(Roster roster, String id) {
    for (Camper camper in roster.campers.values) {
      if (camper.id == id) {
        removeCamperFromRoster(roster, camper);
        return;
      }
    }
    // TODO: Throw error, camper not in roster
  }

  static void addCamperToRoster(Roster roster, Camper camperToAdd) {
    roster.campers[camperToAdd.id] = camperToAdd;
  }

  static void removeCamperFromRoster(Roster roster, Camper camperToRemove) {
    roster.campers.remove(camperToRemove.id);
  }

  static RxMap<String, Camper> getCampers(Roster roster) {
    return roster.campers.obs;
  }

  static void removeCamper(Roster roster, String camperId) {
    roster.campers.remove(camperId);
  }

  // replaces the camper in roster with camper.id with camper
  // I think ai wrote this and I don't understand why this is helpful yet
  static void updateCamper(Roster roster, Camper camper) {
    if (roster.campers.containsKey(camper.id)) {
      roster.campers[camper.id] = camper;
    }
  }

  static void logRoster(Roster roster) {
    ConsoleController().log(roster.bessToString());
  }

  static void exportPdf(Roster roster, Session currentSession) {
    pw.Document pdf = PdfUtils.rosterToPdf(roster);
    String formattedSessionName = currentSession.name.replaceAll(' ', '_').toLowerCase();
    String formattedTimestamp = roster.formattedUpdatedAt.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '-').toLowerCase();
    PdfUtils.savePdfLocally(pdf, 'master_roster_${formattedSessionName}_$formattedTimestamp.pdf');
  }
}