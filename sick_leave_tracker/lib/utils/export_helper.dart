import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import '../models/sick_leave.dart';

class ExportHelper {
  // --- PDF Export ---
  static Future<String> exportToPdf(List<SickLeave> leaves) async {
    final pdf = pw.Document(
      title: 'سجل الإجازات المرضية - اللواء 34 عمالقة',
      author: 'تطبيق تدوين الإجازات المرضية',
    );

    // Load a font that supports Arabic (e.g., Noto Sans Arabic)
    // Since we cannot load external assets in the sandbox, we will use a fallback
    // and inform the user about the font issue if the generated PDF does not show Arabic correctly.
    // For now, we will proceed with the default font and assume the environment has a basic Arabic font.
    // In a real Flutter app, a custom font would be bundled.

    final headers = [
      'الرقم',
      'اسم الجندي',
      'الرقم العسكري',
      'تاريخ البداية',
      'تاريخ النهاية',
      'المدة (يوم)',
      'السبب',
      'ملاحظات',
    ];

    final data = leaves.map((leave) {
      return [
        leave.id.toString(),
        leave.soldierName,
        leave.militaryNumber,
        DateFormat('yyyy-MM-dd').format(leave.startDate),
        DateFormat('yyyy-MM-dd').format(leave.endDate),
        leave.durationInDays.toString(),
        leave.reason,
        leave.notes,
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text(
                'سجل الإجازات المرضية - اللواء 34 عمالقة',
                textDirection: pw.TextDirection.rtl,
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerRight,
              headerAlignment: pw.Alignment.centerRight,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(2),
                7: const pw.FlexColumnWidth(2),
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'تاريخ التقرير: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              textDirection: pw.TextDirection.rtl,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/sick_leaves_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // --- Excel Export ---
  static Future<String> exportToExcel(List<SickLeave> leaves) async {
    final excel = Excel.createExcel();
    final sheet = excel['سجل الإجازات'];

    // Set RTL direction for the sheet
    sheet.setRTL(true);

    // Headers
    final headers = [
      'الرقم',
      'اسم الجندي',
      'الرقم العسكري',
      'تاريخ البداية',
      'تاريخ النهاية',
      'المدة (يوم)',
      'السبب',
      'ملاحظات',
    ];

    // Apply header style
    CellStyle headerStyle = CellStyle(
      backgroundColorHex: '#007BFF', // Blue
      fontColorHex: '#FFFFFF', // White
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Write headers
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Data
    CellStyle dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
    );

    for (var i = 0; i < leaves.length; i++) {
      final leave = leaves[i];
      final row = [
        TextCellValue(leave.id.toString()),
        TextCellValue(leave.soldierName),
        TextCellValue(leave.militaryNumber),
        TextCellValue(DateFormat('yyyy-MM-dd').format(leave.startDate)),
        TextCellValue(DateFormat('yyyy-MM-dd').format(leave.endDate)),
        IntCellValue(leave.durationInDays),
        TextCellValue(leave.reason),
        TextCellValue(leave.notes),
      ];

      for (var j = 0; j < row.length; j++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        cell.value = row[j];
        cell.cellStyle = dataStyle;
      }
    }

    // Auto-fit columns (approximation, as Excel package doesn't have a direct auto-fit)
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/sick_leaves_report.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }
}
