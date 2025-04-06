import 'dart:io';

import 'package:ember_core/ember_core_models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/pdf_styles.dart';

class PdfService extends GetxService{
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
                children: [
                  generateHeaderRow(),
                  ...campers.map((camper) => camperToPaddedTableRow(camper)),
                ],
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
      print('Error saving pdf locally');
    }
  }
}
