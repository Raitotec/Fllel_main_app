import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Views/wallet_redesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    LanguageData.languageData = 'ar';
    DelegateData.delegateData = DelegateDataModel(id: 1, name: 'Local Test');
  });
  tearDown(() => DelegateData.delegateData = null);
  Future<void> open(WidgetTester tester, WalletSubmit submit) async {
    await tester.runAsync(() async {
      await (FontLoader('Cairo')..addFont(rootBundle.load('lib/assets/fonts/Cairo.ttf'))).load();
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Directionality(textDirection: TextDirection.rtl,
      child: BalancePage(loadBalance: (_) async => '250.00', submitRequest: submit))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/wallet-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('invalid amounts and empty description cannot submit', (tester) async {
    var calls = 0;
    await open(tester, (_, __, ___) async { calls++; return true; });
    for (final amount in ['0', '-50', 'NaN', '1.234', '1,000']) {
      await tester.enterText(find.byKey(const ValueKey('wallet-amount')), amount);
      await tester.tap(find.text('إرسال طلب الشحن'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    }
    await tester.enterText(find.byKey(const ValueKey('wallet-amount')), '50');
    await tester.tap(find.text('إرسال طلب الشحن'));
    await tester.pumpAndSettle();
    expect(calls, 0);
  });
  testWidgets('Arabic amount submits exactly once without instant credit', (tester) async {
    var calls = 0;
    String? captured;
    final pending = Completer<bool?>();
    await open(tester, (_, description, amount) { calls++; captured = amount; return pending.future; });
    await tester.enterText(find.byKey(const ValueKey('wallet-amount')), '٥٠٫٢٥');
    await tester.enterText(find.byKey(const ValueKey('wallet-notes')), 'Local funding request');
    await tester.tap(find.text('إرسال طلب الشحن'));
    await tester.pump();
    await tester.tap(find.text('جارٍ الإرسال…'));
    await tester.pump();
    expect(calls, 1);
    expect(captured, '50.25');
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('تم إرسال طلب الشحن للمراجعة.'), findsOneWidget);
    expect(find.text('250.00'), findsOneWidget);
  });
}
