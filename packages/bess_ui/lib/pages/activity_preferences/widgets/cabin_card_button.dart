import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';

class CabinCardButton extends StatelessWidget {
  const CabinCardButton({
    super.key,
    required this.cabinId,
    required this.name,
    required this.count,
    required this.preferenceCount,
    required this.controller,
  });

  final String cabinId;
  final String name;
  final int count;
  final int preferenceCount;
  final ActivityPreferencesController controller;


  @override
  Widget build(BuildContext context) {
    onTap() => controller.navigateToCampers(cabinId, name);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: BessRoundedContainer(
          showBorder: true,
          borderThickness: 2,
          height: 90,
          width: 250,
          clipContent: false,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: BessTextStyles.boldCardTitle),
              const SizedBox(height: 8),
              Text(
                '$preferenceCount/$count Campers completed',
                style: BessTextStyles.largerLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}