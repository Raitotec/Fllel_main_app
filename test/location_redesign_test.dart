import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/map_location_page.dart';
import 'package:babco/Shared_Data/ServicesData.dart';
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
      home: MapLocationScreen()));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/location-picker-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('location validates coordinate pairs and commits only on confirmation', (tester) async {
    AddressData.addressData = 'Existing address';
    AddressData.lat = 1;
    AddressData.lng = 2;
    await open(tester);
    expect(AddressData.addressData, 'Existing address');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Local station address');
    await tester.enterText(fields.at(1), '91');
    await tester.enterText(fields.at(2), '46.6753');
    await tester.tap(find.text('تثبيت العنوان'));
    await tester.pumpAndSettle();
    expect(find.text('إحداثيات غير صالحة'), findsOneWidget);
    expect(AddressData.lat, 1);
    await tester.enterText(fields.at(1), '٢٤٫٧١٣٦');
    await tester.tap(find.text('تثبيت العنوان'));
    await tester.pumpAndSettle();
    expect(AddressData.addressData, 'Local station address');
    expect(AddressData.lat, 24.7136);
    expect(AddressData.lng, 46.6753);
    expect(tester.takeException(), isNull);
  });
}
