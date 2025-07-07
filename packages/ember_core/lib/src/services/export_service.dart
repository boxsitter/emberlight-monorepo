import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../ember_core.dart';
import '../utils/pdf_styles.dart';

class ExportService extends GetxService {
  static pw.TableRow camperToPaddedTableRow(Camper camper) {
    return pw.TableRow(
      children: [
        CorePdfStyles.paddedText(camper.lastName, CorePdfStyles.tableCellTextStyle),
        CorePdfStyles.paddedText(camper.name, CorePdfStyles.tableCellTextStyle),
        CorePdfStyles.paddedText(camper.age.toString(), CorePdfStyles.tableCellTextStyle),
        CorePdfStyles.paddedText(camper.gender, CorePdfStyles.tableCellTextStyle),
        CorePdfStyles.paddedText(camper.cabinName ?? 'none', CorePdfStyles.tableCellTextStyle),
      ],
    );
  }

  static pw.TableRow generateHeaderRow() {
    return pw.TableRow(
      decoration: CorePdfStyles.tableHeaderDecoration,
      children: [
        CorePdfStyles.paddedText('Last Name', CorePdfStyles.tableHeaderTextStyle),
        CorePdfStyles.paddedText('First Name', CorePdfStyles.tableHeaderTextStyle),
        CorePdfStyles.paddedText('Age', CorePdfStyles.tableHeaderTextStyle),
        CorePdfStyles.paddedText('Gender', CorePdfStyles.tableHeaderTextStyle),
        CorePdfStyles.paddedText('Cabin', CorePdfStyles.tableHeaderTextStyle),
      ],
    );
  }

  /// Generates a PDF document from a set of campers.
  static pw.Document campersToPdf(Set<Camper> campers, {String title = 'Campers'}) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final columnWidths = calculateDynamicColumnWidthsForCampers(campers);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(title, style: CorePdfStyles.rosterTitleTextStyle),
                  pw.Text('Count: ${campers.length}', style: CorePdfStyles.rosterSizeTextStyle),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: columnWidths,
                children: [generateHeaderRow(), ...campers.map((camper) => camperToPaddedTableRow(camper))],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Calculates dynamic column widths for a set of campers based on the longest content.
  static Map<int, pw.TableColumnWidth> calculateDynamicColumnWidthsForCampers(Set<Camper> campers) {
    final headers = ['Last Name', 'First Name', 'Age', 'Gender', 'Cabin'];
    final longestItems = List<String>.from(headers);

    for (final camper in campers) {
      if (camper.lastName.length > longestItems[0].length) {
        longestItems[0] = camper.lastName;
      }
      if (camper.name.length > longestItems[1].length) {
        longestItems[1] = camper.name;
      }
      if (camper.age.toString().length > longestItems[2].length) {
        longestItems[2] = camper.age.toString();
      }
      if (camper.gender.length > longestItems[3].length) {
        longestItems[3] = camper.gender;
      }
      final cabinName = camper.cabinName ?? 'none';
      if (cabinName.length > longestItems[4].length) {
        longestItems[4] = cabinName;
      }
    }

    return Map<int, pw.TableColumnWidth>.fromIterable(
      headers.asMap().keys,
      value: (index) => pw.FixedColumnWidth((longestItems[index].length * 7.0) + 10),
    );
  }

  static Future<void> savePdfLocally(pw.Document pdf, String fileName) async {
    try {
      // Open a save file dialog.
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // If the user cancels the dialog, exit early.
      if (filePath == null) {
        return;
      }

      // Write the PDF to the selected file path.
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      Debug.logInfo('Error saving pdf locally');
    }
  }

  /// Exports a list of roster groups to a CSV formatted string.
  ///
  /// If `selectedItems` is provided, only those items will be included in the export.
  /// If multiple groups are provided, group headers are added for readability,
  /// and the column headers are repeated for each group.
  static String exportToCsv({
    required List<RosterGroup> groups,
    required List<RosterField> columns,
    required List<ActivityDependent> activityDependents,
    required Map<PrincipalActivityId, PrincipalActivity> principalActivities,
    Set<Rosterable>? selectedItems,
  }) {
    final StringBuffer csvBuffer = StringBuffer();
    final bool isGrouped = groups.length > 1;
    final bool hasSelection = selectedItems != null && selectedItems.isNotEmpty;

    // 1. Create the header string
    final header = columns.map((field) => _escapeCsvField(field.title)).join(',');

    // If not grouped, write the header once at the top.
    // For grouped data, the header will be written for each group inside the loop.
    if (!isGrouped) {
      csvBuffer.writeln(header);
      csvBuffer.writeln('');
    }

    // 2. Add the data rows, with group headers if necessary
    for (final group in groups) {
      // Filter items if a selection is provided
      final itemsToExport = hasSelection ? group.items.where((item) => selectedItems.contains(item)).toList() : group.items;

      // Skip this group if it has no items to export
      if (itemsToExport.isEmpty) {
        continue;
      }

      // If the data is grouped, add the group title and the column headers
      if (isGrouped) {
        if (group.title.isNotEmpty) {
          String groupTitle = group.title; // Default to the original title
          try {
            // This will only succeed if the group.title is a valid ID for an activity dependent.
            final activityDependent = activityDependents.firstWhere((dep) => dep.id == group.title);
          final principalActivity = principalActivities[activityDependent.principalPar];
          if (principalActivity != null) {
              groupTitle = principalActivity.name; // If found, update the title
          }
          } catch (e) {
            // If firstWhere throws an error (no element found), we do nothing.
            // The groupTitle remains the original group.title, which is the desired behavior
            // for groups not based on an ActivityDependent.
          }

          csvBuffer.writeln(_escapeCsvField(groupTitle));
        }
        csvBuffer.writeln(header);
        csvBuffer.writeln('');
      }

      // Add data rows for each item in the group
      for (final item in itemsToExport) {
        final row = columns
            .map((field) {
              String value;
              if (field is AMABlock) {
                value = _getActivityDependentName(item, field, activityDependents, principalActivities);
              } else {
                value = item.getFieldAsString(field);
              }
              return _escapeCsvField(value);
            })
            .join(',');
        csvBuffer.writeln(row);
      }

      // Add a blank line between groups for readability
      if (isGrouped) {
        csvBuffer.writeln('');
        csvBuffer.writeln('');
      }
    }

    return csvBuffer.toString();
  }

  /// Escapes a field for CSV format.
  ///
  /// - If the field contains a comma, a double quote, or a newline,
  ///   it will be enclosed in double quotes.
  /// - Existing double quotes within the field will be escaped by doubling them.
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      // Escape double quotes by replacing them with two double quotes
      final escapedField = field.replaceAll('"', '""');
      // Enclose the field in double quotes
      return '"$escapedField"';
    }
    return field;
  }

  /// Resolves the name of an activity dependent.
  static String _getActivityDependentName(
    Rosterable rosterItem,
    RosterField field,
    List<ActivityDependent> activityDependents,
    Map<PrincipalActivityId, PrincipalActivity> principalActivities,
  ) {
    String activityDependentId = rosterItem.getFieldAsString(field);
    if (activityDependentId.isEmpty) {
      return 'Unassigned';
    }

    ActivityDependent? activityDependent;
    try {
      activityDependent = activityDependents.firstWhere((dep) => dep.id == activityDependentId);
    } catch (e) {
      // 'firstWhere' throws an error if no element is found.
      // We catch it and leave activityDependent as null.
    }

    if (activityDependent == null) {
      return 'Error (not found)';
    }

    final principalActivity = principalActivities[activityDependent.principalPar];
    return principalActivity?.name ?? 'Error (no principal)';
  }
}
