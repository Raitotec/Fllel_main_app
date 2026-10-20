import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/pay_page.dart';
import 'package:babco/Models/OrderModel.dart';
import 'dart:async';
import 'package:babco/Shared_Data/CartData.dart';
import 'package:babco/Models/ServicesModel.dart';
import 'package:babco/ViewModels/PersonInformationViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

OrderModel? sent; int calls = 0; Completer<String?> pending = Completer<String?>(); void main() {
  setUp(() {
    LanguageData.languageData = 'ar';
    DelegateData.delegateData = DelegateDataModel(id: 1, name: 'Local Test',
      email: 'test@example.com', mobile: '0512345678');
  });
  tearDown(() => DelegateData.delegateData = null);
  Future<void> open(WidgetTester tester) async {
    await tester.runAsync(() async {
      await (FontLoader('Cairo')..addFont(rootBundle.load('lib/assets/fonts/Cairo.ttf'))).load();
      await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(locale: Locale('ar'), supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [TranslationsDelegate(), GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: PayPage(submitOrder: (_, order) { sent = order; calls++; return pending.future; }, obj: [(ServicesModel(1, 'خدمات المحطة', '', true, [ServicesDetailsModel(10, 'خدمة 1', 25, true)..quantity = 2, ServicesDetailsModel(11, 'خدمة 2', 40, true)..quantity = 1, ServicesDetailsModel(12, 'خدمة 3', 15, false)..quantity = 1])..type = '0')])));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/checkout-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('checkout validates address and sends quantities and unit prices once', (tester) async {
    await open(tester);
    await tester.tap(find.text('تأكيد الطلب'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('أدخل عنوان الخدمة'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Local test address');
    await tester.tap(find.text('تأكيد الطلب'));
    await tester.pump();
    expect(calls, 1);
    expect(sent!.totalCost, '90.00');
    expect(sent!.details!.first.quantity, '2.0');
    expect(sent!.details!.first.cost, '25.0');
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('لم يتم تأكيد الطلب. أعد المحاولة.'), findsOneWidget);
    expect(validCart(tester.widget<PayPage>(find.byType(PayPage)).obj), isTrue);
    expect(tester.takeException(), isNull);
  });
}
