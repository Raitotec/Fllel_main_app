import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/LoginPages/login_page.dart';
import 'package:babco/ViewModels/LoginViewModel/LoginViewModel.dart';
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
    expect(find.text('أدخل بيانات تسجيل الدخول'), findsOneWidget);
    final vm = tester.element(find.byType(Form)).read<LoginViewModel>();
    expect(vm.isSubscription, isFalse);
    expect(find.byType(TextField), findsOneWidget);
    await tester.tap(find.text('اشتراكات'));
    await tester.pumpAndSettle();
    expect(vm.isSubscription, isTrue);
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('كلمة المرور لا تقل عن 6 أحرف'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isTrue);
    await tester.tap(find.byTooltip('إظهار كلمة المرور'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Form))));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText, isFalse);
    await tester.enterText(find.byType(TextField).last, 'secret123');
    await tester.tap(find.text('اشتراكات'));
    await tester.pumpAndSettle();
    expect(vm.isSubscription, isFalse);
    expect(vm.passwordController.text, isEmpty);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('both login modes accept mobile and email', (tester) async {
    await open(tester);
    final vm = tester.element(find.byType(Form)).read<LoginViewModel>();
    for (final subscription in [false, true]) {
      if (vm.isSubscription != subscription) {
        await tester.tap(find.text('اشتراكات'));
        await tester.pumpAndSettle();
      }
      for (final identifier in ['0512345678', 'test@example.com']) {
        await tester.enterText(find.byType(TextFormField).first, identifier);
        if (subscription) {
          await tester.enterText(find.byType(TextFormField).last, 'secret123');
        }
        expect(vm.formKey.currentState!.validate(), isTrue);
        await tester.pump();
      }
    }
    expect(tester.takeException(), isNull);
  });

}

