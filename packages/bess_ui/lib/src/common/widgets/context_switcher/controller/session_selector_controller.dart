import 'package:get/get.dart';

// Assuming frameworks is accessible here or passed in
const frameworks = {
  'sessiona': 'Session A',
  'sessionb': 'Session B',
  'testsession': 'Test Session',
};

class SessionSelectorController extends GetxController {
  // Observable for the currently selected session key in the dropdown
  final RxnString selectedSessionKey = RxnString(); // Nullable observable

  // Method to update the selection from the dropdown
  void updateSelection(String? key) {
    selectedSessionKey.value = key;
  }

  // Method triggered by the 'Commit' button within the content widget
  void commitSelection() {
    // Close the dialog currently being shown and return the selected key
    if (selectedSessionKey.value != null) {
      Get.back(result: selectedSessionKey.value);
    }
    // Optionally handle the case where commit is called with null (e.g., show error)
    // though the button should be disabled.
  }

  // Helper to get the display name for the dropdown items
  String? getFrameworkName(String? key) {
    return key != null ? frameworks[key] : null;
  }

  // Provide access to the options for the dropdown
  List<MapEntry<String, String>> get sessionOptions => frameworks.entries.toList();
}
