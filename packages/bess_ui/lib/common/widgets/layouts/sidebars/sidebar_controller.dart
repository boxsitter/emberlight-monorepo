import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/device/device_utility.dart';

class SidebarController extends GetxController {
  final activeItem = BessRoutes.home.obs;
  final hoverItem = ''.obs;

  void changeActiveItem(String route) => activeItem.value = route;

  void changeHoverItem(String route) {
    if (!isActive(route)) hoverItem.value = route;
  }

  bool isActive(String route) => activeItem.value == route;

  bool isHovering(String route) => hoverItem.value == route;

  void menuOnTap(String route) {
    if (!isActive(route)) {
      changeActiveItem(route);

      if (BessDeviceUtils.isMobileScreen(Get.context!) ||
          BessDeviceUtils.isTabletScreen(Get.context!)) {
        Get.back();
      }

      Get.toNamed(route);
    }
  }
}
