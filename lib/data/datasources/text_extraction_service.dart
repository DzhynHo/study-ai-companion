import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class TextExtractionService {
  /// Ekstraktuje tekst z PDF lokalnie (bez AI)
  Future<String> extractTextFromPdf(Uint8List pdfBytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final StringBuffer buffer = StringBuffer();

      for (int i = 0; i < document.pages.count; i++) {
        final text = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (text.trim().isNotEmpty) {
          buffer.writeln('--- Strona ${i + 1} ---');
          buffer.writeln(text);
        }
      }

      document.dispose();
      final result = buffer.toString().trim();
      return result.isEmpty ? 'Nie udało się wyciągnąć tekstu z PDF.' : result;
    } catch (e) {
      throw Exception('Błąd ekstrakcji PDF: $e');
    }
  }

  /// Czyści i formatuje tekst
  String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }
}
