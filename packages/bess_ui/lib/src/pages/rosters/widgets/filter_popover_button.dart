import 'package:bess_ui/src/pages/rosters/controllers/rosters_controller.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/misc/list_reorderer.dart';

/// A button that, when pressed, reveals a popover with a form
/// for selecting visible columns.
class FilterPopoverButton extends StatefulWidget {
  const FilterPopoverButton({super.key, required this.controller});

  final RostersController controller;

  @override
  State<FilterPopoverButton> createState() => _FilterPopoverButtonState(controller: controller);
}

class _FilterPopoverButtonState extends State<FilterPopoverButton> {
  final popoverController = ShadPopoverController();
  final RostersController controller;

  _FilterPopoverButtonState({required this.controller});

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      // The popover contains the stateless form widget.
      popover: (context) => _FilterForm(
        controller: controller,
        shadController: popoverController,
      ),
      // This is the button that triggers the popover.
      child: ShadIconButton.secondary(
        height: 30,
        width: 30,
        padding: EdgeInsets.zero,
        icon: const Icon(
          LucideIcons.listFilter500,
          size: 18,
        ),
        onPressed: popoverController.toggle,
        backgroundColor: BessColors.core,
      ),
    );
  }
}

class _FilterForm extends StatelessWidget {
  const _FilterForm({
    super.key,
    required this.controller,
    required this.shadController,
  });

  final RostersController controller;
  final ShadPopoverController shadController;

  @override
  Widget build(BuildContext context) {
    // GetBuilder will listen to controller.update() calls and rebuild the UI
    return GetBuilder<RostersController>(
      init: controller,
      builder: (controller) {
        return SizedBox(
          width: 380, // A bit wider to accommodate the UI
          child: Padding(
            padding: const EdgeInsets.all(BessSizes.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- VISIBILITY & ORDER SECTION ---
                Text('Visible Columns', style: BessTextStyles.standardBold),
                const SizedBox(height: BessSizes.sm),
                Container(
                  height: 200, // Increased height for better scrolling
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(color: BessColors.borderPrimary),
                    borderRadius: BorderRadius.circular(BessSizes.borderThicknessMd),
                  ),
                  child: VerticalListReorderer(
                    items: controller.fields,
                    onReorder: controller.setColumnOrder,
                    trailingBuilder: (Titled item) {
                      // You can safely assume the item is the RosterField for this row
                      final field = item as RosterField;
                      return IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        // The onPressed callback now knows which 'field' to remove
                        onPressed: () => controller.removeVisibleColumn(field),
                        splashRadius: 20,
                      );
                    }
                  ),
                ),
                const SizedBox(height: BessSizes.sm),
                // Using standard DropdownButtonFormField to add a column
                DropdownButtonFormField<RosterField>(
                  hint: const Text('Add column...'),
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BessSizes.borderThicknessMd),
                      borderSide: BorderSide(color: BessColors.borderPrimary),
                    ),
                  ),
                  items: controller.availableFields.map((field) {
                    return DropdownMenuItem(value: field, child: Text(field.title));
                  }).toList(),
                  onChanged: (field) {
                    if (field != null) {
                      controller.addVisibleColumn(field);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
