// Verification harness for the Built-in Kotlin migration — exercises the Android
// Kotlin implementation end to end on a real device. Loads a PDF with Flutter's
// own asset API (bypassing PdfDocument.openAsset, which is broken on current
// Flutter for reasons unrelated to the Kotlin migration) and renders a page.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pdfx/pdfx.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('openData + render page exercises the Android Kotlin path', () async {
    final bytes = (await rootBundle.load('assets/hello.pdf')).buffer.asUint8List();
    expect(bytes.length, greaterThan(1000), reason: 'asset should be a real PDF');
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');

    final document = await PdfDocument.openData(bytes);
    expect(document.pagesCount, greaterThan(0));

    final page = await document.getPage(1);
    expect(page.width, greaterThan(0));
    expect(page.height, greaterThan(0));

    final image = await page.render(width: page.width, height: page.height);
    expect(image, isNotNull);
    expect(image!.bytes.length, greaterThan(0));

    await page.close();
    await document.close();
  });
}
