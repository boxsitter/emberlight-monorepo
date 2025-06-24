// import 'package:flutter/material.dart';
// import '../../../../common/constants/sizes.dart';
//
// class HeaderCheckbox extends StatelessWidget {
//   final int totalRowCount;
//   final int selectedRowCount;
//   final ValueChanged<bool?>? onChanged;
//
//   const HeaderCheckbox({
//     super.key,
//     required this.totalRowCount,
//     required this.selectedRowCount,
//     this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool? checkboxValue;
//     if (selectedRowCount == 0) {
//       checkboxValue = false;
//     } else if (selectedRowCount == totalRowCount) {
//       checkboxValue = true;
//     } else {
//       // This is the indeterminate state
//       checkboxValue = null;
//     }
//
//     return Container(
//       width: 50,
//       padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: 0),
//       child: Align(
//         alignment: Alignment.center,
//         child: Checkbox(
//           tristate: true, // Enable tristate behavior
//           value: checkboxValue,
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
// }