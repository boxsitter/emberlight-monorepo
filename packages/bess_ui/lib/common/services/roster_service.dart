import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/camper.dart';
import '../../data/models/local_data.dart';
import '../../data/models/roster.dart';
import '../../pages/console/controller/console_controller.dart';
import '../feature_utils/pdf_utils.dart';

class RosterService extends GetxService {
  final LocalData localData = Get.find<LocalData>();

  RxMap<String, Camper> getCampers(Roster roster) {
    return roster.campers.obs;
  }

  void addCamper(Roster roster, Camper camper) {
    roster.campers[camper.id] = camper;
    roster.updateTimestamp();
  }

  void removeCamper(Roster roster, String camperId) {
    roster.campers.remove(camperId);
    roster.updateTimestamp();
  }

  void updateCamper(Roster roster, Camper camper) {
    if (roster.campers.containsKey(camper.id)) {
      roster.campers[camper.id] = camper;
      roster.updateTimestamp();
    }
  }

  void logRoster(Roster roster) {
    ConsoleController().log(roster.bessToString());
  }

  void exportPdf(Roster roster) {
    pw.Document pdf = PdfUtils.rosterToPdf(roster);
    String formattedSessionName = localData.session!.name.replaceAll(' ', '_').toLowerCase();
    String formattedTimestamp = roster.formattedUpdatedAt.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '-').toLowerCase();
    PdfUtils.savePdfLocally(pdf, 'master_roster_${formattedSessionName}_$formattedTimestamp.pdf');
  }
}