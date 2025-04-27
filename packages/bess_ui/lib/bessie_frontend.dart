import 'package:ember_core/ember_core_frontend.dart';
import 'package:get/get.dart';

import 'common/services/popup_service.dart';

const _frontendName = 'Bessie';
const _frontendDescription = 'Cross-platform app interface for managing summer camp logistics with EmberCore';

class BessieFrontend implements CoreFrontend {
  final PopupService popupService = Get.find<PopupService>();

  @override
  String get frontendName => _frontendName;

  @override
  String get frontendDescription => _frontendDescription;

  @override
  void displayError({String? title, String? message}) {
    popupService.showToast(title: title, message: message); // TODO: Make a separate toast design for errors
  }

  @override
  void displayInfo({String? title, String? message}) {
    popupService.showToast(title: title, message: message);
  }

  @override
  Future<bool> getConfirmation({required String title, String? message, Map<String, List<String>>? foldedSubcontent}) {
    return popupService.showConfirmationDialog(title: title, message: message);
  }


}