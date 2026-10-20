import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/PersonInformationPage.dart';
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
      home: PersonInformationPage()));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/profile-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('invalid profile fields cannot reach account saving', (tester) async {
    await open(tester);
    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), 'a');
    await tester.enterText(inputs.at(1), 'invalid');
    await tester.enterText(inputs.at(2), '123');
    await tester.tap(find.text('حفظ التغييرات'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل اسمًا لا يقل عن حرفين'), findsOneWidget);
    expect(find.text('أدخل بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    expect(find.text('أدخل رقم جوال صحيحًا يبدأ بـ05'), findsOneWidget);
    final vm = Provider.of<PersonInformationViewModel>(tester.element(find.byType(Form)), listen: false);
    expect(vm.isLoading, isFalse);
  });
  testWidgets('cancelling password editing clears both masked inputs', (tester) async {
    await open(tester);
    await tester.ensureVisible(find.text('تعديل'));
    await tester.tap(find.text('تعديل'));
    await tester.pumpAndSettle();
    final vm = Provider.of<PersonInformationViewModel>(tester.element(find.byType(Form)), listen: false);
    vm.currentPasswordController.text = 'local-current';
    vm.newPasswordController.text = 'local-new';
    await tester.pump();
    expect(tester.widgetList<TextField>(find.byType(TextField)).where((field) => field.obscureText).length, 2);
    await tester.ensureVisible(find.text('إلغاء').first);
    await tester.tap(find.text('إلغاء').first);
    await tester.pumpAndSettle();
    expect(vm.showPasswordFields, isFalse);
    expect(vm.currentPasswordController.text, isEmpty);
    expect(vm.newPasswordController.text, isEmpty);
  });
}
