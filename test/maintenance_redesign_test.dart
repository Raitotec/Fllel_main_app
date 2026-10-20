import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/StationMaintenancePage.dart';
import 'package:babco/Models/MaintenanceModel.dart';
import 'package:babco/ViewModels/PersonInformationViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

MaintenanceRequest? sent; int calls = 0; void main() {
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
      home: StationMaintenancePage(loadServices: (_) async => [MaintenanceModel(1, 'صيانة المضخات')], submitRequest: (_, request) async { sent = request; calls++; return false; })));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/maintenance-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('maintenance validates station information before submission', (tester) async {
    await open(tester);
    await tester.tap(find.text('إرسال طلب الصيانة'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('اختر خدمة الصيانة'), findsOneWidget);
    expect(find.text('هذا الحقل مطلوب'), findsWidgets);
    await tester.ensureVisible(find.byType(DropdownButtonFormField<MaintenanceModel>));
    await tester.tap(find.byType(DropdownButtonFormField<MaintenanceModel>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('صيانة المضخات').last);
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Local test station');
    await tester.ensureVisible(fields.at(3));
    await tester.enterText(fields.at(3), 'Local test address');
    await tester.tap(find.text('إرسال طلب الصيانة'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(sent!.station, 'Local test station');
    expect(sent!.serviceId, '1');
    expect(sent!.comment, contains('Local Test'));
    expect(sent!.imagePaths, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

