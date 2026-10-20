import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Models/DelegateDataModel.dart';
import 'package:babco/Shared_Data/DelegateData.dart';
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Localization/TranslationsDelegate.dart';
import 'package:babco/Views/rate_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:babco/ViewModels/PersonInformationViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

int calls = 0; String? sentRating; void main() {
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
      home: RatePage(obj: 'local-order-code', submitRating: (_, rating, comment) async { calls++; sentRating = rating; return false; })));
    await tester.pumpAndSettle();
    await tester.runAsync(() => precacheImage(const AssetImage('lib/assets/fal_brand.png'), tester.element(find.byType(Scaffold))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('design-audit/screenshots/rating-local-preview.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }
  testWidgets('rating requires a choice and stays on screen after failed submission', (tester) async {
    await open(tester);
    await tester.ensureVisible(find.text('إرسال التقييم'));
    await tester.tap(find.text('إرسال التقييم'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('اختر تقييمك أولاً'), findsOneWidget);
    tester.widget<RatingBar>(find.byType(RatingBar)).onRatingUpdate(4.5);
    await tester.pump();
    await tester.tap(find.text('إرسال التقييم'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(sentRating, '4.5');
    expect(find.byType(RatePage), findsOneWidget);
    expect(find.text('لم يُرسل التقييم، أعد المحاولة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
