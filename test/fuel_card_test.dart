import 'dart:io';
import 'dart:ui' as ui;
import 'package:babco/Shared_Data/LanguageData.dart';
import 'package:babco/Views/fuel_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
class Fixture extends FuelCardSource {
 DateTime Function() now = DateTime.now;
 int calls = 0;
 bool fail = false;
 @override
 Future<FuelCardData> loadCard() async => const FuelCardData(name: 'أحمد محمد', employeeNumber: '1024', available: 80, allowance: 200, fuel: 'بنزين ٩٥', period: 'أكتوبر ٢٠٢٦');
 @override
 Future<FuelCode> issueCode() async { calls++; if(fail) throw StateError('offline'); return FuelCode('LOCAL-PREVIEW-$calls', now().add(const Duration(seconds: 30))); }
 @override
 Future<FuelHistory> history(DateTime month, int page) async => FuelHistory([
 FuelMovement(id:'1048',station:'محطة حي القادسية',date:DateTime(2026,10,20,10,30),litres:30,fuel:'بنزين ٩٥',customerName:'أحمد محمد',employeeNumber:'1024',unitPrice:2.33,totalValue:69.90,taxIncluded:true),
 FuelMovement(id:'1032',station:'محطة طريق الدمام',date:DateTime(2026,10,18,9,15),litres:40,fuel:'بنزين ٩٥'),
 FuelMovement(id:'1016',station:'محطة حي القادسية',date:DateTime(2026,10,15,18,45),litres:20,fuel:'بنزين ٩٥'),
 FuelMovement(id:'1004',station:'محطة طريق الملك سعود',date:DateTime(2026,10,10,8,20),litres:30,fuel:'بنزين ٩٥'),
 FuelMovement(id:'0992',station:'محطة حي النخيل',date:DateTime(2026,10,5),litres:25,fuel:'بنزين ٩٥',cancelled:true),
 ],totalLitres:120,totalCount:4);
}
Future<void> open(WidgetTester t, Widget child) async {
 LanguageData.languageData='ar';
 await t.runAsync(() async {
 await (FontLoader('Cairo')..addFont(rootBundle.load('lib/assets/fonts/Cairo.ttf'))).load();
 await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
 });
 await t.binding.setSurfaceSize(const Size(400,1100));
 addTearDown(()=>t.binding.setSurfaceSize(null));
 await t.pumpWidget(MaterialApp(builder:(context, page)=>Directionality(textDirection:TextDirection.rtl,child:page!),home:child));
 await t.pumpAndSettle();
}
Future<void> shot(WidgetTester t,String name) async {
 await t.runAsync(() async {
 final b=t.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
 final im=await b.toImage(pixelRatio:2);final bytes=await im.toByteData(format:ui.ImageByteFormat.png);
 await File('design-audit/screenshots/$name.png').writeAsBytes(bytes!.buffer.asUint8List()); im.dispose();
 });
}
void main(){
 testWidgets('QR expires and failed renewal removes old code', (t) async {
 final f=Fixture();var now=DateTime.now();f.now=()=>now;await open(t,FuelCardPage(source:f,now:()=>now));
 expect(find.byType(QrImageView),findsOneWidget);await shot(t,'fuel-card-local-preview');
 f.fail=true;now=now.add(const Duration(seconds:31));await t.pump(const Duration(seconds:1));await t.pump();
 expect(find.byType(QrImageView),findsNothing);expect(f.calls,2);
 await t.pumpWidget(const SizedBox());
 });
 testWidgets('history excludes cancelled when completed selected',(t) async {
 await open(t,FuelHistoryPage(source:Fixture()));await shot(t,'fuel-history-local-preview');
 await t.tap(find.text('مكتملة').first);await t.pumpAndSettle();
 expect(find.text('محطة حي النخيل'),findsNothing);expect(t.takeException(),isNull);
 });
 testWidgets('history opens prepaid details and returns to the same history',(t) async {
 await open(t,FuelHistoryPage(source:Fixture()));
 await t.tap(find.text('محطة حي القادسية').first);await t.pumpAndSettle();
 expect(find.text('تفاصيل التعبئة'),findsOneWidget);
 expect(find.text('لا يوجد مبلغ مستحق عليك'),findsOneWidget);
 expect(find.text('69.90 ر.س'),findsOneWidget);
 await shot(t,'fuel-details-local-preview');
 await t.tap(find.text('الرجوع للحركات'));await t.pumpAndSettle();
 expect(find.text('حركات الوقود'),findsOneWidget);
 });
 testWidgets('cancelled detail never invents missing prices or tax',(t) async {
 await open(t,FuelMovementDetailsPage(movement:FuelMovement(id:'1',station:'محطة',date:DateTime(2026),litres:20,fuel:'95',cancelled:true)));
 expect(find.text('عملية ملغاة'),findsOneWidget);
 expect(find.text('—'),findsNWidgets(2));
 expect(find.text('القيمة المعروضة تشمل الضريبة'),findsNothing);
 expect(t.takeException(),isNull);
 });
 testWidgets('unconfigured service never displays a fake QR',(t) async {
 await open(t,const FuelCardPage());expect(find.byType(QrImageView),findsNothing);
 expect(find.textContaining('لم يكتمل ربط'),findsOneWidget);await t.pumpWidget(const SizedBox());
 });
}
