import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/grocery_list.dart';
import '../models/list_item.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  ExportService._();

  /// Formats the shopping list into a beautiful Plain Text representation.
  static String exportToText(GroceryList list, List<ListItem> items) {
    final buffer = StringBuffer();
    buffer.writeln(list.name);
    if (list.hasBudget) {
      buffer.writeln('Budget: ${CurrencyFormatter.formatWhole(list.budget!)}');
    }
    buffer.writeln();

    for (final item in items) {
      final prefix = item.isCompleted ? '✓' : '□';
      final priceSuffix = item.hasPrice
          ? ' - ${CurrencyFormatter.formatWhole(item.estimatedCost)}'
          : '';
      buffer.writeln('$prefix ${item.name} (${item.quantity} ${item.unit})$priceSuffix');
    }

    final total = items.fold(0.0, (sum, item) => sum + item.estimatedCost);
    buffer.writeln();
    buffer.writeln('Total: ${CurrencyFormatter.formatWhole(total)}');

    if (list.hasBudget) {
      final remaining = list.budget! - total;
      buffer.writeln('Remaining: ${CurrencyFormatter.formatWhole(remaining)}');
    }

    return buffer.toString();
  }

  /// Formats the shopping list into a standard CSV representation.
  static String exportToCSV(GroceryList list, List<ListItem> items) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('Name,Quantity,Price,Purchased,Budget');

    for (final item in items) {
      final name = item.name.replaceAll('"', '""');
      final qty = item.quantity;
      final price = item.unitPrice ?? 0.0;
      final purchased = item.isCompleted ? 'Yes' : 'No';
      final budget = list.budget ?? 0.0;
      buffer.writeln('"$name",$qty,$price,$purchased,$budget');
    }

    return buffer.toString();
  }

  /// Generates a printable PDF using standard pdf/widgets.
  static Future<pw.Document> generatePDF(GroceryList list, List<ListItem> items) async {
    final pdf = pw.Document();
    final total = items.fold(0.0, (sum, item) => sum + item.estimatedCost);
    final remaining = list.budget != null ? list.budget! - total : 0.0;
    final dateStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header List Name & Date
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      list.name,
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 16),

                // Budget Metadata Cards
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (list.hasBudget)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Budget:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(CurrencyFormatter.formatWhole(list.budget!)),
                        ],
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Total Estimated Cost:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(CurrencyFormatter.formatWhole(total)),
                      ],
                    ),
                    if (list.hasBudget)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Remaining:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            CurrencyFormatter.formatWhole(remaining),
                            style: pw.TextStyle(
                              color: remaining >= 0 ? PdfColors.green : PdfColors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Table of Items
                pw.Text('Items List', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Quantity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Price/Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Cost', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...items.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.isCompleted ? 'Purchased' : 'Pending')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.name)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${item.quantity} ${item.unit}')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(item.unitPrice != null ? CurrencyFormatter.formatWhole(item.unitPrice!) : '₱0')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(CurrencyFormatter.formatWhole(item.estimatedCost))),
                      ],
                    )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }

  /// Triggers standard system share for plain text.
  static Future<void> shareText(String text, String subject) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        title: subject,
      ),
    );
  }

  /// Triggers system share for a file (CSV or PDF).
  static Future<void> shareFile(String content, String filename, String subject, {bool isPDF = false, List<int>? pdfBytes}) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');

    if (isPDF && pdfBytes != null) {
      await file.writeAsBytes(pdfBytes);
    } else {
      await file.writeAsString(content);
    }

    await SharePlus.instance.share(
      ShareParams(
        title: subject,
        files: [XFile(file.path)],
      ),
    );
  }

  /// Prints the PDF directly using printing package.
  static Future<void> printPDF(GroceryList list, List<ListItem> items) async {
    final doc = await generatePDF(list, items);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${list.name}.pdf',
    );
  }
}
