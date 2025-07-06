import 'package:bess_ui/src/common/mixins/route_aware_controller_mixin.dart';
import 'package:bess_ui/src/common/widgets/buttons/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../constants/colors.dart';
import 'controllers/menu_bar_controller.dart';

class BessMenuBar<T extends RouteAwareControllerMixin> extends StatelessWidget {
  const BessMenuBar({
    super.key,
    this.externalPageController,
    this.pageTitle,
    this.fileItems,
    this.viewItems,
    this.editItems,
    this.additionalItems,
    this.helpItems,
  });

  final T? externalPageController;
  final String? pageTitle;
  final List<Widget>? fileItems;
  final List<Widget>? viewItems;
  final List<Widget>? editItems;
  final List<Widget>? additionalItems;
  final List<Widget>? helpItems;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuBarController>(
      builder: (internalController) {
        // A function to construct the menu bar. This can be called from different
        // builder paths to avoid duplicating code.
        Widget buildActualMenuBar() {
          final divider = ShadSeparator.horizontal(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: BessColors.borderPrimary,
          );

          List<Widget> menuItems = [];

          menuItems.add(
            BessIconButton(iconData: internalController.sidebarHidden == true ? LucideIcons.arrowRightFromLine : LucideIcons.arrowLeftFromLine, radius: 0, margin: 0, onPressed: internalController.toggleHideSidebar,),
          );
          
          menuItems.add(
            ShadMenubarItem(
              buttonDecoration: ShadDecoration(border: ShadBorder(radius: BorderRadius.zero)),
              child: const Text('File'),
              items: [
                if (fileItems != null) ...fileItems!,
              ],
            ),
          );

          // Edit Menu (conditional)
          if (editItems != null && editItems!.isNotEmpty) {
            menuItems.add(
              ShadMenubarItem(
                buttonDecoration: ShadDecoration(border: ShadBorder(radius: BorderRadius.zero)),
                child: const Text('Edit'),
                items: editItems!,
              ),
            );
          }

          // View Menu
          menuItems.add(
            ShadMenubarItem(
              buttonDecoration: ShadDecoration(border: ShadBorder(radius: BorderRadius.zero)),
              child: const Text('View'),
              items: [
                ShadContextMenuItem(
                  child: const Text('Hide Sidebar'),
                  onPressed: internalController.toggleHideSidebar,
                  leading: internalController.sidebarHidden
                      ? Icon(
                          LucideIcons.check,
                          color: BessColors.textPrimary,
                        )
                      : const Icon(
                          LucideIcons.check,
                          color: Colors.transparent,
                        ),
                ),
                if (viewItems != null) divider,
                if (viewItems != null) ...viewItems!,
              ],
            ),
          );

          // Additional Items
          if (additionalItems != null) {
            menuItems.addAll(additionalItems!);
          }

          // Help Menu
          menuItems.add(
            ShadMenubarItem(
              buttonDecoration: ShadDecoration(border: ShadBorder(radius: BorderRadius.zero)),
              child: const Text('Help'),
              items: [
                const ShadContextMenuItem(
                  child: Text('Coming soon'),
                ),
                const ShadContextMenuItem(
                  child: Text('For now, help yourself'),
                ),
                if (helpItems != null) ...helpItems!,
              ],
            ),
          );

          return ShadMenubar(
            selectOnHover: false,
            backgroundColor: Colors.transparent,
            radius: BorderRadius.zero,
            items: menuItems,
          );
        }

        // Conditionally listen to the external controller ONLY if it exists.
        // This prevents the null error.
        if (externalPageController != null) {
          return GetBuilder<T>(builder: (extController) {
            // Rebuilds when either internal or external controller updates.
            return buildActualMenuBar();
          });
        } else {
          // Only rebuilds when the internal controller updates.
          return buildActualMenuBar();
        }
      },
    );
  }
}
