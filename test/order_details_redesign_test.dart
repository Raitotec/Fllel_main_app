import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/RequestsModel.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Views/order_details_redesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  Future<void> open(WidgetTester tester, RequestsModel order) async {
    LanguageData.languageData = 'ar';
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() async {
      await (FontLoader('Cairo')..addFont(rootBundle.load('lib/assets/fonts/Cairo.ttf'))).load();
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    await tester.pumpWidget(MaterialApp(home: Directionality(textDirection: TextDirection.rtl,
      child: RequestsDetailsPage(obj: order))));
    await tester.pumpAndSettle();
  }
  testWidgets('uses exact server code and server total without recomputing', (tester) async {
    final order = RequestsModel(id: 1042, status: 'underexecute', date: '2026-10-12', totalCost: '150.00',
      details: [RequestsDetails(productName: 'Local first service', quantity: '2', cost: '50.00'),
        RequestsDetails(productName: 'Local second service', quantity: '1', cost: '50.00')])..url = 'https://example.com/local-order-check';
    await open(tester, order);
    expect(find.text('150.00'), findsOneWidget);
    expect(find.text('الكمية: 2'), findsOneWidget);
    await tester.ensureVisible(find.byType(QrImageView)); await tester.pumpAndSettle();
    final paint = tester.widget<CustomPaint>(find.descendant(of: find.byType(QrImageView), matching: find.byType(CustomPaint)));
    await tester.runAsync(() async {
      final expected = QrPainter(data: order.url!, version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M, gapless: true);
      final actualBytes = await (paint.painter! as QrPainter).toImageData(230);
      final expectedBytes = await expected.toImageData(230);
      expect(actualBytes!.buffer.asUint8List(), orderedEquals(expectedBytes!.buffer.asUint8List()));
    });
    await tester.drag(find.byType(ListView), const Offset(0, 1000)); await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/order-detail-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List()); image.dispose();
    });
  });
  testWidgets('missing code and empty items are safe', (tester) async {
    await open(tester, RequestsModel(id: 1, status: 'custom-status', totalCost: '0.00'));
    expect(find.text('custom-status'), findsOneWidget);
    expect(find.text('لا توجد تفاصيل متاحة للطلب'), findsOneWidget);
    expect(find.text('رمز الطلب غير متاح حاليًا'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
  });
}
