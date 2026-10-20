import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Models/RequestsModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Views/orders_redesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() { LanguageData.languageData = 'ar'; DelegateData.delegateData = DelegateDataModel(id: 1); });
  tearDown(() => DelegateData.delegateData = null);
  final orders = [RequestsModel(id: 1042, status: 'underexecute', totalCost: '150.00', date: '2026-10-12'),
    RequestsModel(id: 1041, status: 'completed', totalCost: '85.00', date: '2026-10-10'),
    RequestsModel(id: 1040, status: 'custom-status', totalCost: '120.00', date: '2026-10-08')];
  Future<void> open(WidgetTester tester) async {
    await tester.runAsync(() async {
      await (FontLoader('Cairo')..addFont(rootBundle.load('lib/assets/fonts/Cairo.ttf'))).load();
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Directionality(textDirection: TextDirection.rtl,
      child: RequestsPage(loadOrders: (_) async => orders))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/orders-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('filters preserve unknown statuses under all', (tester) async {
    await open(tester);
    expect(find.text('custom-status'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('orders-filter-1'))); await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-1042')), findsOneWidget);
    expect(find.byKey(const ValueKey('order-1041')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('orders-filter-2'))); await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-1041')), findsOneWidget);
    expect(find.byKey(const ValueKey('order-1042')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('orders-filter-0'))); await tester.pumpAndSettle();
    expect(find.text('custom-status'), findsOneWidget);
  });
  testWidgets('search accepts Arabic digits and reports no matches', (tester) async {
    await open(tester);
    await tester.enterText(find.byKey(const ValueKey('order-search')), '١٠٤٢'); await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('order-1042')), findsOneWidget);
    expect(find.byKey(const ValueKey('order-1041')), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('order-search')), '99999'); await tester.pumpAndSettle();
    expect(find.text('لا توجد طلبات مطابقة'), findsOneWidget);
  });
}
