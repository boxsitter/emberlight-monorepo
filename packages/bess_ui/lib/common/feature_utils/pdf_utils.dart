import 'dart:io';
import 'dart:typed_data';

import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/data/models/schedule/assignable_activity_block.dart';
import 'package:bessie/pages/console/controller/console_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';
import '../styles/pdf_styles.dart';

class PdfUtils {
  static pw.TableRow camperToPaddedTableRow(Camper camper) {
    return pw.TableRow(
      children: [
        BessPdfStyles.paddedText(
            camper.lastName, BessPdfStyles.tableCellTextStyle),
        BessPdfStyles.paddedText(camper.name, BessPdfStyles.tableCellTextStyle),
        BessPdfStyles.paddedText(
            camper.age.toString(), BessPdfStyles.tableCellTextStyle),
        BessPdfStyles.paddedText(
            camper.gender, BessPdfStyles.tableCellTextStyle),
        BessPdfStyles.paddedText(
            BessIdFunctions.cabinNameFromId(camper.cabinId, ''), BessPdfStyles.tableCellTextStyle),
      ],
    );
  }

  static pw.TableRow generateHeaderRow() {
    return pw.TableRow(
      decoration: BessPdfStyles.tableHeaderDecoration,
      children: [
        BessPdfStyles.paddedText(
            'Last Name', BessPdfStyles.tableHeaderTextStyle),
        BessPdfStyles.paddedText(
            'First Name', BessPdfStyles.tableHeaderTextStyle),
        BessPdfStyles.paddedText('Age', BessPdfStyles.tableHeaderTextStyle),
        BessPdfStyles.paddedText('Gender', BessPdfStyles.tableHeaderTextStyle),
        BessPdfStyles.paddedText('Cabin', BessPdfStyles.tableHeaderTextStyle),
      ],
    );
  }

  static pw.Document rosterToPdf(Roster roster) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final columnWidths = calculateDynamicColumnWidths(roster);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(roster.title,
                      style: BessPdfStyles.rosterTitleTextStyle),
                  pw.Text('Roster Size: ${roster.length}',
                      style: BessPdfStyles.rosterSizeTextStyle),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: columnWidths,
                children: [
                  generateHeaderRow(), // Dynamic header row
                  ...roster.values
                      .map((camper) => camperToPaddedTableRow(camper)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Document assignableActivityBlockToPdf(
      AssignedMultiActivityBlock block) {
    final pdf = pw.Document();

    // Iterate through each activity in the block
    for (int i = 0; i < block.activities.length; i++) {
      final pdf = pw.Document();

      for (final activity in block.activities.values) {
        // Generate a PDF for each roster
        final rosterPdf = rosterToPdf(activity.roster);

        // Save the roster PDF as bytes
        final rosterBytes = rosterPdf.save();

        // Add the roster PDF content to the main document
        pdf.addPage(
          pw.Page(
            build: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(pw.MemoryImage(rosterBytes as Uint8List)),
            ),
          ),
        );

        // Add a dashed separator if it's not the last activity
        if (activity != block.activities.values.last) {
          pdf.addPage(
            pw.Page(
              build: (context) => pw.Center(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text(
                    '------------------------------------------------------------',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return pdf;
  }

  // Calculate dynamic column widths based on longest content
  static Map<int, pw.TableColumnWidth> calculateDynamicColumnWidths(
      Roster roster) {
    // Headers as keys and longest values as placeholders
    final headers = ['Last Name', 'First Name', 'Age', 'Gender', 'Cabin'];
    final longestItems = List<String>.from(headers);

    for (final camper in roster.values) {
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
      if ((BessIdFunctions.cabinNameFromId(camper.cabinId, '')).length > longestItems[4].length) {
        longestItems[4] = BessIdFunctions.cabinNameFromId(camper.cabinId, '');
      }
    }

    // Dynamically calculate column widths based on content length
    return Map<int, pw.TableColumnWidth>.fromIterable(
      headers.asMap().keys,
      value: (index) => pw.FixedColumnWidth((longestItems[index].length * 7.0) +
          10), // 7px per character + padding
    );
  }

  static Future<void> savePdfLocally(pw.Document pdf, String fileName) async {
    try {
      // Open a save file dialog
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // If the user canceled the dialog, exit early
      if (filePath == null) {
        ConsoleController().error('Save operation canceled.');
        return;
      }

      // Write the PDF to the selected file path
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ConsoleController().success('PDF saved successfully at $filePath');
    } catch (e) {
      ConsoleController().error('Error saving PDF: $e');
    }
  }
}
