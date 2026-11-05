import 'dart:async';
import '../Shared_Data/QrEncryption.dart';
import '../Api/Fuel/FuelCardApi.dart';
import '../Models/FuelCardModel.dart';
export '../Models/FuelCardModel.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Shared_View/FalDesign.dart';

// Optional source for previewing card and movement data.
abstract class FuelCardSource {
  Future<FuelCardData> loadCard();
  Future<FuelCode> issueCode();
  Future<FuelHistory> history(DateTime month, int page);
}
class FuelCode {
  const FuelCode(this.value, this.expiresAt);
  final String value;
  final DateTime expiresAt;
}
class FuelMovement {
  const FuelMovement({required this.id, required this.station, required this.date, required this.litres, required this.fuel, this.cancelled = false, this.customerName, this.employeeNumber, this.unitPrice, this.totalValue, this.taxIncluded, this.operationNumber, this.vehicleNumber, this.balanceBefore, this.balanceAfter});
  final String id, station, fuel;
  final DateTime date;
  final double litres;
  final bool cancelled;
  final String? customerName, employeeNumber, operationNumber, vehicleNumber;
  final double? unitPrice, totalValue, balanceBefore, balanceAfter;
  final bool? taxIncluded;
}
class FuelHistory {
  const FuelHistory(this.items, {this.hasMore = false, this.totalLitres, this.totalCount, this.totalAmount});
  final List<FuelMovement> items;
  final bool hasMore;
  final double? totalLitres, totalAmount;
  final int? totalCount;
}
class FuelCardPage extends StatefulWidget {
  const FuelCardPage({super.key, this.source, this.now = DateTime.now});
  final FuelCardSource? source;
  final DateTime Function() now;
  @override
  State<FuelCardPage> createState() => _FuelCardPageState();
}
class _FuelCardPageState extends State<FuelCardPage> with WidgetsBindingObserver {
  FuelCardData? _card;
  String? _identificationQr;
  FuelCode? _code;
  List<FuelMovement> _recent = [];
  bool _loading = false, _issuing = false, _foreground = true;
  String? _error;
  Timer? _timer;
  int get seconds => _code == null ? 0 : (_code!.expiresAt.difference(widget.now()).inMilliseconds / 1000).ceil().clamp(0, 30);
  @override
  void initState() {
    super.initState(); WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_foreground || !mounted) return;
      if (_code != null && seconds == 0) { _code = null; _issue(); }
      setState(() {});
    });
  }
  @override
  void dispose() { _timer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) { setState(() => _code = null); }
    else if (_card?.active == true) { _load(); }
  }
  Future<void> _load() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; _code = null; });
    try {
      final card = widget.source == null
          ? await GetFuelCard(context)
          : await widget.source!.loadCard();
      if (card == null) return;
      final recent = widget.source == null ? null : await widget.source!.history(widget.now(), 1);
      if (!mounted) return;
      String? identificationQr;
      if (widget.source == null && (card.beneficiaryId ?? 0) > 0) {
        try {
          identificationQr = FuelQrEncryption()
              .encode(card.beneficiaryId!);
        } catch (_) {
          debugPrint('Unable to generate encrypted fuel QR');
        }
      }
      setState(() { _identificationQr = identificationQr; _card = card; _recent = recent?.items.take(3).toList() ?? []; });
      if (card.active && _foreground) await _issue();
    } catch (_) { if (mounted) setState(() => _error = falText('تعذّر تحميل بطاقة الوقود. حاول مجددًا', 'Unable to load your fuel card. Try again')); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _issue() async {
    if (_issuing || widget.source == null || _card?.active != true || !_foreground) return;
    setState(() { _issuing = true; _code = null; });
    try {
      final code = await widget.source!.issueCode();
      if (!mounted || !_foreground) return;
      final duration = code.expiresAt.difference(widget.now());
      if (code.value.isEmpty || duration <= Duration.zero || duration > const Duration(seconds: 31)) throw StateError('Invalid expiry');
      setState(() { _code = code; _error = null; });
    } catch (_) { if (mounted) setState(() => _error = falText('تعذّر تجديد الكود. أعد المحاولة', 'Unable to refresh code. Try again')); }
    finally { if (mounted) setState(() => _issuing = false); }
  }
  @override
  Widget build(BuildContext context) {
    final card = _card;
    return FalPage(title: falText('بطاقتي للوقود', 'My fuel card'), body: RefreshIndicator(onRefresh: _load,
      child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(18), children: [
        if (_loading && card == null) const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator()))
        else if (card != null) ...[
          falCard([Row(children: [const CircleAvatar(backgroundColor: Color(0xFFFFF5CE), child: Icon(Icons.person_outline, color: falBlue)), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(card.name, style: falStyle(18, weight: FontWeight.w800)), if (card.employeeNumber.isNotEmpty) Text('${falText('الرقم الوظيفي', 'Employee number')} ${card.employeeNumber}', style: falStyle(12))])),
            if (card.showStatus) Text(card.active ? falText('بطاقة نشطة', 'Active') : falText('بطاقة موقوفة', 'Inactive'), style: falStyle(11, color: card.active ? Colors.green.shade700 : Colors.grey))])]),
          Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [falBlue, falInk]), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(card.amountBased ? falText('الرصيد المتاح', 'Available balance') : falText('الكمية المتاحة', 'Available fuel'), style: falStyle(14, color: Colors.white)), Text('${card.available == null ? '—' : _number(card.available!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}', style: falStyle(38, color: falGold, weight: FontWeight.w800)),
            Text('${falText('من أصل', 'of')} ${card.allowance == null ? '—' : _number(card.allowance!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}', style: falStyle(12, color: Colors.white)), const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: card.remainingRatio, minHeight: 9, color: falGold, backgroundColor: Colors.white24)), const SizedBox(height: 12),
            Text('${card.fuel}  •  ${card.period}', style: falStyle(12, color: Colors.white)), Text('${falText('المستهلك', 'Used')} ${card.consumedValue == null ? '—' : _number(card.consumedValue!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}', style: falStyle(12, color: Colors.white))])),
          if (widget.source == null && _identificationQr != null) falCard([
            Text(falText('كود التعريف', 'Identification code'), textAlign: TextAlign.center, style: falStyle(23, weight: FontWeight.w800)),
            Text(falText('اعرض الكود لموظف التعبئة', 'Show this code to the station attendant'), textAlign: TextAlign.center, style: falStyle(13)),
            const SizedBox(height: 16),
            Center(child: QrImageView(key: const ValueKey('fuel-beneficiary-qr'), data: _identificationQr!, size: 230, padding: const EdgeInsets.all(20), backgroundColor: Colors.white)),
            const SizedBox(height: 12),
            Text(falText('الكود للتعريف فقط، ولا ينفّذ تعبئة', 'This code identifies you only; it does not record a refill'), textAlign: TextAlign.center, style: falStyle(12, color: falBlue)),
          ]),
          if (widget.source == null && _identificationQr == null) falCard([
            Text(falText('تعذّر عرض كود التعريف', 'Unable to display identification code'), textAlign: TextAlign.center, style: falStyle(14)),
          ]),
          if (widget.source != null) falCard([Text(falText('كود التعريف', 'Identification code'), textAlign: TextAlign.center, style: falStyle(23, weight: FontWeight.w800)), Text(falText('اعرض الكود لموظف التعبئة', 'Show this code to the station attendant'), textAlign: TextAlign.center, style: falStyle(13)), const SizedBox(height: 16),
            if (_code != null && seconds > 0 && _foreground) Center(child: QrImageView(data: _code!.value, size: 230, padding: const EdgeInsets.all(20), backgroundColor: Colors.white))
            else SizedBox(height: 210, child: Center(child: _issuing ? const CircularProgressIndicator() : Icon(card.active ? Icons.qr_code_2 : Icons.lock_outline, size: 80, color: Colors.blueGrey))),
            if (_code != null && seconds > 0) Center(child: SizedBox(width: 72, height: 72, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: seconds / 30, strokeWidth: 5, backgroundColor: const Color(0xFFE7EFF6))), Text('00:${seconds.toString().padLeft(2, '0')}', style: falStyle(17))]))),
            const SizedBox(height: 14), Text(falText('يتجدد تلقائيًا كل ٣٠ ثانية', 'Refreshes automatically every 30 seconds'), textAlign: TextAlign.center, style: falStyle(12)),
            const SizedBox(height: 12), Text(falText('الكود للتعريف فقط، ولا ينفّذ تعبئة', 'This code identifies you only; it does not record a refill'), textAlign: TextAlign.center, style: falStyle(12, color: falBlue)),
            OutlinedButton.icon(onPressed: _issuing || !card.active ? null : _issue, icon: const Icon(Icons.refresh), label: Text(falText('تجديد الكود', 'Refresh code')))]),
          if (card.vehicle.isNotEmpty) falCard([
            Text(falText('بيانات المركبة', 'Vehicle information'), style: falStyle(18, weight: FontWeight.w800)),
            ...card.vehicle.entries.where((entry) => entry.value != null && entry.key != 'id' && entry.key != 'fuel_type').map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5), child: Text('${_vehicleLabel(entry.key)}: ${entry.value}', style: falStyle(13)))),
          ]),
          if (card.allowanceDetails.isNotEmpty) falCard([
            Text(falText('تفاصيل الرصيد', 'Allowance details'), style: falStyle(18, weight: FontWeight.w800)),
            if (card.remainingPercentage != null) _cardDetail(falText('نسبة الرصيد المتبقي', 'Remaining balance'), '${_number(card.remainingPercentage!)}%'),
            if (card.allowanceDetails['period_type'] != null) _cardDetail(falText('دورية الرصيد', 'Allowance period'), _periodLabel(card.allowanceDetails['period_type'].toString())),
            if (card.allowanceDetails['estimated_remaining_volume'] != null) _cardDetail(falText('كمية الوقود المتبقية تقديريًا (لتر)', 'Estimated remaining fuel (L)'), _apiNumber(card.allowanceDetails['estimated_remaining_volume'])),
            if (card.allowanceDetails['estimated_at_unit_price'] != null) _cardDetail(falText('سعر اللتر المستخدم للتقدير', 'Estimated unit price'), '${_apiNumber(card.allowanceDetails['estimated_at_unit_price'], decimals: 4)} ${falText('ر.س', 'SAR')}'),
          ]),
          if (card.contract.isNotEmpty) falCard([
            Text(falText('بيانات العقد', 'Contract information'), style: falStyle(18, weight: FontWeight.w800)),
            if (card.billingName.isNotEmpty) Text(card.billingName, style: falStyle(14)),
            if (card.contract['contract_number'] != null) Text('${card.contract['contract_number']}', style: falStyle(13)),
            if (card.contract['starts_on'] != null) _cardDetail(falText('بداية العقد', 'Contract starts'), card.contract['starts_on'].toString()),
            if (card.contract['ends_on'] != null) Text('${falText('انتهاء العقد', 'Contract ends')}: ${card.contract['ends_on']}', style: falStyle(13)),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(falText('آخر التعبئات', 'Recent refills'), style: falStyle(19, weight: FontWeight.w800)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FuelHistoryPage(source: widget.source))), child: Text(falText('عرض الكل', 'View all')))]),
          if (_recent.isEmpty && card.lastRefill == null) Text(falText('لا توجد تعبئات سابقة', 'No previous refills'), style: falStyle(14)),
          if (_recent.isEmpty && card.lastRefill != null) falCard([
            if (card.lastRefill!['station_name'] != null) _cardDetail(falText('المحطة', 'Station'), card.lastRefill!['station_name'].toString()),
            if (card.lastRefill!['actual_amount'] != null) _cardDetail(falText('قيمة آخر تعبئة', 'Last refill amount'), '${_apiNumber(card.lastRefill!['actual_amount'])} ${falText('ر.س', 'SAR')}'),
            if (card.lastRefill!['volume'] != null) _cardDetail(falText('الكمية (لتر)', 'Volume (L)'), _apiNumber(card.lastRefill!['volume'])),
            if (card.lastRefill!['filled_at'] != null) _cardDetail(falText('تاريخ التعبئة', 'Refill date'), _refillDate(card.lastRefill!['filled_at'])),
          ]),
          ..._recent.map((item) => _movement(context, item)),
        ],
        if (!_loading && card == null && _error == null) TextButton(onPressed: _load, child: Text(falText('إعادة المحاولة', 'Retry'))),
        if (_error != null) ...[Text(_error!, style: falStyle(13, color: Colors.red.shade700)), TextButton(onPressed: _load, child: Text(falText('إعادة المحاولة', 'Retry')))],
      ])));
  }
}
Widget _cardDetail(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 5),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Text(label, style: falStyle(13))), const SizedBox(width: 12),
    Expanded(child: Text(value, textAlign: TextAlign.end, style: falStyle(13, weight: FontWeight.w700))),
  ]),
);
String _apiNumber(dynamic value, {int decimals = 2}) {
  final number = double.tryParse(value.toString());
  return number == null || !number.isFinite ? '—' : number.toStringAsFixed(decimals);
}
String _periodLabel(String value) => {
  'monthly': falText('شهري', 'Monthly'),
  'weekly': falText('أسبوعي', 'Weekly'),
  'daily': falText('يومي', 'Daily'),
  'yearly': falText('سنوي', 'Yearly'),
}[value] ?? value;
String _refillDate(dynamic value) {
  final date = DateTime.tryParse(value.toString());
  if (date == null) return value.toString();
  return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
String _vehicleLabel(String key) => {
  'vehicle_number': falText('رقم المركبة', 'Vehicle number'),
  'vehicle_type': falText('نوع المركبة', 'Vehicle type'),
  'vehicle_model': falText('موديل المركبة', 'Vehicle model'),
  'manufacturing_year': falText('سنة الصنع', 'Manufacturing year'),
  'vehicle_color': falText('اللون', 'Color'),
}[key] ?? key;
String _number(num value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);
class FuelMovementDetailsPage extends StatefulWidget {
  const FuelMovementDetailsPage({super.key, required this.movement});
  final FuelMovement movement;
  @override
  State<FuelMovementDetailsPage> createState() => _FuelMovementDetailsPageState();
}
class _FuelMovementDetailsPageState extends State<FuelMovementDetailsPage> {
  late Future<Map<String, dynamic>> _details;
  @override
  void initState() { super.initState(); _details = GetFuelRefillDetails(widget.movement.id); }
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _details,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return FalPage(title: falText('تفاصيل التعبئة', 'Refill details'), body: const Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return FalPage(title: falText('تفاصيل التعبئة', 'Refill details'), body: ListView(padding: const EdgeInsets.all(18), children: [
          Text(snapshot.error.toString().replaceFirst('Exception: ', ''), style: falStyle(14, color: Colors.red)),
          OutlinedButton(onPressed: () => setState(() { _details = GetFuelRefillDetails(widget.movement.id); }), child: Text(falText('إعادة المحاولة', 'Retry'))),
        ]));
      }
      final data = snapshot.data!;
      final movement = _historyFromJson({'items': [data]}).items.single;
      return _FuelMovementDetailsContent(movement: movement, data: data);
    },
  );
}
class _FuelMovementDetailsContent extends StatelessWidget {
  const _FuelMovementDetailsContent({required this.movement, required this.data});
  final Map<String, dynamic> data;
  final FuelMovement movement;
  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Text(label, style: falStyle(13, color: const Color(0xFF718198)))), const SizedBox(width: 16),
    Expanded(child: Text(value, textAlign: TextAlign.end, style: falStyle(14, weight: FontWeight.w700))),
  ]));
  String money(double? value) => value == null || !value.isFinite || value < 0 ? '—' : '${value.toStringAsFixed(2)} ${falText('ر.س', 'SAR')}';
  @override
  Widget build(BuildContext context) {
    final m = movement;
    final contract = data['contract'] is Map ? data['contract'] as Map : {};
    final billing = contract['billing_customer'] is Map ? contract['billing_customer'] as Map : {};
    final allowance = data['allowance'] is Map ? data['allowance'] as Map : {};
    final attachments = data['attachments'] is List ? data['attachments'] as List : [];
    return FalPage(title: falText('تفاصيل التعبئة', 'Refill details'), body: ListView(padding: const EdgeInsets.all(18), children: [
      Center(child: Chip(avatar: Icon(m.cancelled ? Icons.cancel_outlined : Icons.check_circle, color: m.cancelled ? Colors.grey : Colors.green.shade700),
        backgroundColor: m.cancelled ? const Color(0xFFF0F1F3) : const Color(0xFFE9F6ED), side: BorderSide.none,
        label: Text(m.cancelled ? falText('عملية ملغاة', 'Cancelled transaction') : falText('عملية مكتملة', 'Completed transaction'), style: falStyle(15)))),
      Text('${falText('عملية رقم', 'Transaction')} #${m.operationNumber ?? m.id}', textAlign: TextAlign.center, style: falStyle(23, weight: FontWeight.w800)),
      Text('${m.date.day}/${m.date.month}/${m.date.year} • ${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}', textAlign: TextAlign.center, style: falStyle(13, color: const Color(0xFF718198))),
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [falBlue, falInk]), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(falText('كمية الوقود', 'Fuel quantity'), style: falStyle(16, color: Colors.white)),
          Text('${_number(m.litres)} ${falText('لتر', 'L')}', style: falStyle(42, weight: FontWeight.w800, color: falGold)),
          Text(m.fuel, style: falStyle(16, color: Colors.white)),
        ])), const Icon(Icons.local_gas_station_outlined, size: 85, color: Color(0xFF86B2D4))])),
      const SizedBox(height: 16),
      if (m.customerName != null) falCard([Row(children: [const Icon(Icons.verified_user_outlined, size: 36, color: falBlue), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(falText('تعبئة الوقود', 'Fuel refill'), style: falStyle(15, weight: FontWeight.w800)),
        Text(falText('لا يوجد مبلغ مستحق عليك', 'No payment is due from you'), style: falStyle(13)),
      ]))])], color: const Color(0xFFECF6FE)),
      falCard([Text(falText('بيانات التعبئة', 'Refill information'), style: falStyle(18, weight: FontWeight.w800)),
        _row(falText('المحطة', 'Station'), m.station),
        if (m.vehicleNumber != null) _row(falText('رقم المركبة', 'Vehicle number'), m.vehicleNumber!),
        if (m.balanceBefore != null) _row(falText('الرصيد قبل التعبئة', 'Balance before'), money(m.balanceBefore)),
        if (m.balanceAfter != null) _row(falText('الرصيد بعد التعبئة', 'Balance after'), money(m.balanceAfter)),
        if (m.customerName?.isNotEmpty == true) ...[const Divider(height: 1), _row(falText('العميل', 'Customer'), m.customerName!)],
        if (m.employeeNumber?.isNotEmpty == true) ...[const Divider(height: 1), _row(falText('الرقم الوظيفي', 'Employee number'), m.employeeNumber!)],
      ]),
      falCard([Text(falText('قيمة التعبئة', 'Refill value'), style: falStyle(18, weight: FontWeight.w800)),
        _row(falText('سعر اللتر وقت التعبئة', 'Unit price at refill'), money(m.unitPrice)), const Divider(height: 1),
        _row(falText('الكمية', 'Quantity'), '${_number(m.litres)} ${falText('لتر', 'L')}'), const Divider(color: falGold),
        _row(falText('إجمالي القيمة', 'Total value'), money(m.totalValue)),
        if (m.taxIncluded != null) Text(m.taxIncluded! ? falText('القيمة المعروضة تشمل الضريبة', 'Value includes tax') : falText('القيمة المعروضة لا تشمل الضريبة', 'Value excludes tax'), style: falStyle(12, color: const Color(0xFF718198))),
        if (m.totalValue == null && m.unitPrice == null) Text(falText('لم تُرسل بيانات القيمة لهذه الحركة', 'Price information was not provided for this transaction'), style: falStyle(12, color: const Color(0xFF718198))),

      ]),
      if (contract.isNotEmpty) falCard([
        Text(falText('بيانات العقد', 'Contract information'), style: falStyle(18, weight: FontWeight.w800)),
        if (contract['contract_number'] != null) _row(falText('رقم العقد', 'Contract number'), contract['contract_number'].toString()),
        if (billing['name'] != null) _row(falText('جهة الفوترة', 'Billing customer'), billing['name'].toString()),
      ]),
      if (allowance.isNotEmpty) falCard([
        Text(falText('فترة الرصيد', 'Allowance period'), style: falStyle(18, weight: FontWeight.w800)),
        if (allowance['period_type'] != null) _row(falText('الدورية', 'Period'), _periodLabel(allowance['period_type'].toString())),
        if (allowance['starts_on'] != null) _row(falText('من', 'From'), allowance['starts_on'].toString()),
        if (allowance['ends_on'] != null) _row(falText('إلى', 'To'), allowance['ends_on'].toString()),
      ]),
      if (attachments.isNotEmpty) falCard([
        Text(falText('صور التعبئة', 'Refill attachments'), style: falStyle(18, weight: FontWeight.w800)),
        ...attachments.whereType<Map>().where((attachment) => attachment['url'] != null).map((attachment) {
          final url = attachment['url'].toString();
          final label = attachment['kind'] == 'dispenser' ? falText('صورة المضخة', 'Dispenser photo') : attachment['kind'] == 'meter' ? falText('صورة العداد', 'Meter photo') : falText('صورة مرفقة', 'Attachment');
          return Padding(padding: const EdgeInsets.only(top: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(label, style: falStyle(14, weight: FontWeight.w700)), const SizedBox(height: 8),
            InkWell(onTap: () => showDialog<void>(context: context, builder: (context) => Dialog(child: Stack(children: [
              InteractiveViewer(minScale: 0.5, maxScale: 5, child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, error, stack) => Padding(padding: const EdgeInsets.all(24), child: Text(falText('تعذّر تحميل الصورة', 'Unable to load image'))))),
              Positioned(top: 0, right: 0, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))),
            ]))), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, height: 180, fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null ? child : const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
              errorBuilder: (_, error, stack) => SizedBox(height: 100, child: Center(child: Text(falText('تعذّر تحميل الصورة', 'Unable to load image'), style: falStyle(13)))),
            ))),
          ]));
        }),
      ]),
      OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: Text(falText('الرجوع للحركات', 'Back to history'))),
    ]));
  }
}
Widget _movement(BuildContext context, FuelMovement item) => InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FuelMovementDetailsPage(movement: item))),
  child: falCard([Row(children: [const CircleAvatar(backgroundColor: Color(0xFFECF5FC), child: Icon(Icons.local_gas_station_outlined, color: falBlue)), const SizedBox(width: 12),
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.station, style: falStyle(14, weight: FontWeight.w800)), Text('${item.date.day}/${item.date.month}/${item.date.year} • ${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}', style: falStyle(11)), Text('${item.fuel} • #${item.operationNumber ?? item.id}', style: falStyle(11))])), const SizedBox(width: 8),
  Column(children: [Text('${_number(item.litres)} ${falText('لتر', 'L')}', style: falStyle(20, weight: FontWeight.w800)), Text(item.cancelled ? falText('ملغاة', 'Cancelled') : falText('مكتملة', 'Completed'), style: falStyle(11, color: item.cancelled ? Colors.grey : Colors.green.shade700))])])]));
class FuelHistoryPage extends StatefulWidget {
  const FuelHistoryPage({super.key, this.source});
  final FuelCardSource? source;
  @override
  State<FuelHistoryPage> createState() => _FuelHistoryPageState();
}
class _FuelHistoryPageState extends State<FuelHistoryPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final List<FuelMovement> _items = [];
  FuelHistory? _summary;
  int _filter = 1, _page = 0, _request = 0;
  bool _busy = false, _more = false;
  String? _error;
  @override
  void initState() { super.initState(); _load(reset: true); }
  Future<void> _load({bool reset = false}) async {
    if (_busy && !reset) return;
    final request = ++_request;
    final page = reset ? 1 : _page + 1;
    setState(() { _busy = true; _error = null; if (reset) { _items.clear(); _summary = null; _more = false; } });
    try {
      final history = widget.source != null
          ? await widget.source!.history(_month, page)
          : _historyFromJson(await GetFuelRefills(_month, page, _filter == 0 ? null : _filter == 1 ? 'completed' : 'cancelled'));
      if (!mounted || request != _request) return;
      setState(() { _items.addAll(history.items); _summary = history; _page = page; _more = history.hasMore; });
    } catch (e) { if (mounted && request == _request) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted && request == _request) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('حركات الوقود', 'Fuel history'), body: RefreshIndicator(onRefresh: () => _load(reset: true), child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(18), children: [
    Text(falText('تابع تعبئاتك السابقة', 'Track your previous refills'), style: falStyle(15)), const SizedBox(height: 16),
    ...[
      falCard([Text(falText('إجمالي هذا الشهر', 'Monthly total'), style: falStyle(14)), Text('${_summary?.totalLitres == null ? '—' : _number(_summary!.totalLitres!)} ${falText('لتر', 'L')}', style: falStyle(30, weight: FontWeight.w800)), if (_summary?.totalAmount != null) Text('${_number(_summary!.totalAmount!)} ${falText('ر.س', 'SAR')}', style: falStyle(20, weight: FontWeight.w800)), Text('${_summary?.totalCount ?? '—'} ${falText('عمليات', 'transactions')}', style: falStyle(13))], color: const Color(0xFFECF6FE)),
      OutlinedButton.icon(onPressed: () async {
        final chosen = await showDatePicker(context: context, initialDate: _month, firstDate: DateTime(2020), lastDate: DateTime.now());
        if (chosen != null && mounted) { setState(() => _month = DateTime(chosen.year, chosen.month)); _load(reset: true); }
      }, icon: const Icon(Icons.calendar_month), label: Text('${_month.month} / ${_month.year}')),
      const SizedBox(height: 12), SegmentedButton<int>(segments: [ButtonSegment(value: 0, label: Text(falText('الكل', 'All'))), ButtonSegment(value: 1, label: Text(falText('مكتملة', 'Completed'))), ButtonSegment(value: 2, label: Text(falText('ملغاة', 'Cancelled')))], selected: {_filter}, onSelectionChanged: (v) { setState(() => _filter = v.first); _load(reset: true); }), const SizedBox(height: 16),
      ..._items.where((i) => _filter == 0 || (_filter == 2) == i.cancelled).map((item) => _movement(context, item)),
      if (!_busy && _error == null && !_items.any((i) => _filter == 0 || (_filter == 2) == i.cancelled)) Text(falText('لا توجد حركات مطابقة', 'No matching transactions'), style: falStyle(14)),
      if (_busy) const Center(child: CircularProgressIndicator()),
      if (_error != null) Text(_error!, style: falStyle(14, color: Colors.red)),
      if (_error != null || _more) OutlinedButton(onPressed: _busy ? null : () => _load(reset: _page == 0), child: Text(_error != null ? falText('إعادة المحاولة', 'Retry') : falText('عرض المزيد', 'Load more'))),
    ],
  ])));
}

FuelHistory _historyFromJson(Map<String, dynamic> data) {
  double? number(dynamic value) {
    final parsed = double.tryParse(value?.toString() ?? '');
    return parsed != null && parsed.isFinite ? parsed : null;
  }
  final summary = data['summary'] is Map ? data['summary'] as Map : {};
  final pagination = data['pagination'] is Map ? data['pagination'] as Map : {};
  final items = (data['items'] as List? ?? []).map((value) {
    final item = Map<String, dynamic>.from(value as Map);
    return FuelMovement(
      id: item['id'].toString(),
      operationNumber: item['operation_number']?.toString(),
      station: item['station'] is Map ? item['station']['name']?.toString() ?? '' : '',
      vehicleNumber: item['vehicle'] is Map ? item['vehicle']['vehicle_number']?.toString() : null,
      date: DateTime.parse(item['filled_at'].toString()),
      litres: number(item['volume']) ?? 0,
      fuel: item['fuel_type']?.toString() ?? '',
      cancelled: item['status'] == 'cancelled',
      totalValue: number(item['actual_amount']),
      unitPrice: number(item['unit_price']),
      balanceBefore: number(item['balance_before']),
      balanceAfter: number(item['balance_after']),
    );
  }).toList();
  final current = int.tryParse(pagination['current_page']?.toString() ?? '') ?? 1;
  final last = int.tryParse(pagination['last_page']?.toString() ?? '') ?? current;
  return FuelHistory(items, hasMore: current < last,
    totalLitres: number(summary['total_volume']), totalAmount: number(summary['total_amount']),
    totalCount: int.tryParse(summary['operations_count']?.toString() ?? ''));
}
