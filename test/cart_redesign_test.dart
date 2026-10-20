import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/services_selected_page.dart';
import 'package:babco/Shared_Data/CartData.dart';
import 'package:babco/Models/ServicesModel.dart';
import 'package:babco/ViewModels/PersonInformationViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
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
      home: ServicesSelectedPage(obj: [ServicesModel(1, 'خدمات المحطة', '', true, [ServicesDetailsModel(10, 'خدمة 1', 25, true)..quantity = 2, ServicesDetailsModel(11, 'خدمة 2', 40, true)..quantity = 1, ServicesDetailsModel(12, 'خدمة 3', 15, false)..quantity = 1])])));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/cart-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('removing an item preserves remaining quantity times price', (tester) async {
    await open(tester);
    final page = tester.widget<ServicesSelectedPage>(find.byType(ServicesSelectedPage));
    expect(cartTotal(page.obj), 90);
    await tester.tap(find.byTooltip('حذف من السلة').last);
    await tester.pumpAndSettle();
    expect(cartTotal(page.obj), 50);
    await tester.tap(find.byTooltip('زيادة الكمية'));
    await tester.pumpAndSettle();
    expect(cartTotal(page.obj), 75);
    await tester.tap(find.byTooltip('حذف من السلة'));
    await tester.pumpAndSettle();
    expect(find.text('السلة فارغة'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'متابعة الطلب')).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
