import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/tag_constants.dart';
import '../models/tag_credential.dart';
import 'tag_pdf_storage.dart' as pdf_storage;

/// Builds printable/shareable rack tag certificates; saves PDFs to device storage.
class TagCertificatePdfService {
  static String get lastSaveFolderLabel => pdf_storage.tagPdfSaveFolderLabel();

  static String filenameFor(TagCredential credential) =>
      'vblafarm-tag-${credential.tagId}-rack-${credential.rackId}.pdf';

  static Future<Uint8List> buildCertificate(TagCredential credential) async {
    final tagBytes = await rootBundle.load(TagConstants.assetPathForTagId(credential.tagId));
    final tagImage = pw.MemoryImage(tagBytes.buffer.asUint8List());

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green800, width: 2),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            padding: const pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'vBlaFarm',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.Text(
                      'RACK TAG CERTIFICATE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  credential.farmName,
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 24),
                pw.Center(
                  child: pw.Container(
                    width: 200,
                    height: 200,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Image(tagImage, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.SizedBox(height: 24),
                _field('Tag ID', '${credential.tagId}'),
                _field('Family', credential.family),
                _field('Assigned rack', 'Rack ${credential.rackId}'),
                _field('Credential ID', credential.credentialId),
                _field('Issued (UTC)', credential.issuedAt),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Print this certificate and affix the tag to the assigned rack. '
                  'AR Scan reads the physical tag ID and loads rack data from the registry.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
    return doc.save();
  }

  static pw.Widget _field(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// Writes PDF to Downloads/vBlaFarm/tags (Android) or app documents.
  static Future<String> saveCertificateToStorage(TagCredential credential) async {
    final bytes = await buildCertificate(credential);
    return pdf_storage.savePdfBytes(bytes, filenameFor(credential));
  }

  static Future<List<String>> saveAllToStorage(List<TagCredential> credentials) async {
    final paths = <String>[];
    for (final credential in credentials) {
      paths.add(await saveCertificateToStorage(credential));
    }
    return paths;
  }

  static Future<void> printCertificate(TagCredential credential) async {
    if (!kIsWeb) {
      await saveCertificateToStorage(credential);
    }
    final bytes = await buildCertificate(credential);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  static Future<void> shareCertificate(TagCredential credential) async {
    final bytes = await buildCertificate(credential);
    if (!kIsWeb) {
      await saveCertificateToStorage(credential);
    }
    await Printing.sharePdf(
      bytes: bytes,
      filename: filenameFor(credential),
    );
  }
}
