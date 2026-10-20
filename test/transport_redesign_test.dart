import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/StationTransportationPage.dart';
import 'package:babco/ViewModels/PersonInformationViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

String? draft; int calls = 0; void main() {
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
      home: StationTransportationPage(prepareMessage: (_, message, phone) async { draft = message; calls++; })));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/transport-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('transport prepares a draft and never reports a submitted order', (tester) async {
    await open(tester);
    await tester.tap(find.text('متابعة مع الدعم'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Local station');
    await tester.ensureVisible(fields.at(3));
    await tester.enterText(fields.at(3), 'Local address');
    await tester.ensureVisible(find.text('إضافة للقائمة'));
    await tester.tap(find.text('إضافة للقائمة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة للقائمة'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('إزالة الوقود'), findsOneWidget);
    await tester.tap(find.text('متابعة مع الدعم'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(draft, contains('Local station'));
    expect(draft, contains('وقود 90'));
    expect(draft, contains('الكمية: 10'));
    expect(find.byType(StationTransportationPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
