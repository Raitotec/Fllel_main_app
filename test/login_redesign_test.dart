import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/LoginPages/login_page.dart';
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
    await tester.pumpWidget(const MaterialApp(locale: Locale('ar'), supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [TranslationsDelegate(), GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: LoginPage()));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Form))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/login-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('login blocks empty fields and toggles password visibility', (tester) async {
    await open(tester);
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Form))));
    await tester.pumpAndSettle();
    expect(find.text('أدخل البريد الإلكتروني أو رقم الجوال'), findsOneWidget);
    expect(find.text('كلمة المرور لا تقل عن 6 أحرف'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
    await tester.tap(find.byTooltip('إظهار كلمة المرور'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Form))));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
    expect(tester.takeException(), isNull);
  });
}

