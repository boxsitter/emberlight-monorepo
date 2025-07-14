import 'dart:math';
import 'package:intl/intl.dart';

import '../../ember_core.dart';
import 'assignment_constants.dart';

/// Defines the contract for a set of helper functions used by the algorithm.
/// This allows for swapping out the implementation for testing purposes.
abstract class AssignmentHelpers {
  double calculateAgeBonus(DateTime birthdate);

  bool areBlocksAdjacentOnSameDay(AMABlock blockA, AMABlock blockB, List<AMABlock> weeklyBlocksSorted);

  int calculateBlockDistance(AMABlock blockA, AMABlock blockB, List<AMABlock> weeklyBlocksSorted);
}

/// The default, concrete implementation of the assignment helpers.
class DefaultAssignmentHelpers implements AssignmentHelpers {

  // Make this a singleton so we don't create unnecessary instances.
  const DefaultAssignmentHelpers();

  @override
  double calculateAgeBonus(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }

    if (age <= AssignmentConstants.youngerCamperMinAge) {
      return AssignmentConstants.youngerCamperMaxBonus;
    }
    if (age >= AssignmentConstants.youngerCamperMaxAge) {
      return 0.0;
    }

    final ageRange = (AssignmentConstants.youngerCamperMaxAge - AssignmentConstants.youngerCamperMinAge).toDouble();
    final camperPositionInRange = (age - AssignmentConstants.youngerCamperMinAge).toDouble();

    final bonus = AssignmentConstants.youngerCamperMaxBonus * (1 - (camperPositionInRange / ageRange));

    return max(0.0, bonus);
  }

  @override
  bool areBlocksAdjacentOnSameDay(AMABlock blockA, AMABlock blockB, List<AMABlock> weeklyBlocksSorted) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dayA = formatter.format(blockA.start);
    final dayB = formatter.format(blockB.start);

    if (dayA != dayB) return false;

    final indexA = weeklyBlocksSorted.indexWhere((b) => b.id == blockA.id);
    final indexB = weeklyBlocksSorted.indexWhere((b) => b.id == blockB.id);

    if (indexA == -1 || indexB == -1) return false;

    return (indexA - indexB).abs() == 1;
  }

  @override
  int calculateBlockDistance(AMABlock blockA, AMABlock blockB, List<AMABlock> weeklyBlocksSorted) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final dayA = formatter.format(blockA.start);
    final dayB = formatter.format(blockB.start);

    if (dayA != dayB) return -1;

    final indexA = weeklyBlocksSorted.indexWhere((b) => b.id == blockA.id);
    final indexB = weeklyBlocksSorted.indexWhere((b) => b.id == blockB.id);

    if (indexA == -1 || indexB == -1) return -1;

    return (indexA - indexB).abs() - 1;
  }


}
