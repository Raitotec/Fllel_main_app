import 'dart:async';
import '../Routes/route_constants.dart';
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
  const FuelMovement(
      {required this.id,
      required this.station,
      required this.date,
      required this.litres,
      required this.fuel,
      this.cancelled = false,
      this.customerName,
      this.employeeNumber,
      this.unitPrice,
      this.totalValue,
      this.taxIncluded,
      this.operationNumber,
      this.vehicleNumber,
      this.balanceBefore,
      this.balanceAfter});
  final String id, station, fuel;
  final DateTime date;
  final double litres;
  final bool cancelled;
  final String? customerName, employeeNumber, operationNumber, vehicleNumber;
  final double? unitPrice, totalValue, balanceBefore, balanceAfter;
  final bool? taxIncluded;
}

class FuelHistory {
  const FuelHistory(this.items,
      {this.hasMore = false,
      this.totalLitres,
      this.totalCount,
      this.totalAmount});
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

class _FuelCardPageState extends State<FuelCardPage>
    with WidgetsBindingObserver {
  FuelCardData? _card;
  String? _identificationQr;
  DateTime? _identificationExpiresAt;
  FuelCode? _code;
  List<FuelMovement> _recent = [];
  bool _loading = false, _issuing = false, _foreground = true;
  String? _error;
  bool _loginRequired = false;
  Timer? _timer;
  Timer? _refreshTimer;
  int _refreshAttempts = 0;

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshAttempts = 0;
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted || !_foreground || _loginRequired) {
        timer.cancel();
        return;
      }
      _refreshAttempts++;
      if (ModalRoute.of(context)?.isCurrent == true && !_loading) {
        _load(silent: true);
      }
      if (_refreshAttempts >= 5) timer.cancel();
    });
  }
  int get seconds => _code == null
      ? 0
      : (_code!.expiresAt.difference(widget.now()).inMilliseconds / 1000)
          .ceil()
          .clamp(0, 30);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_foreground || !mounted) return;
      if (widget.source == null &&
          _identificationExpiresAt != null &&
          !widget.now().isBefore(_identificationExpiresAt!)) {
        _renewIdentification();
      }
      if (_code != null && seconds == 0) {
        _code = null;
        _issue();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      _refreshTimer?.cancel();
      setState(() {
        _code = null;
        _identificationQr = null;
        _identificationExpiresAt = null;
      });
    } else if (_card?.active == true) {
      _load();
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (_loading) return;
    if (!silent) _startAutoRefresh();
    setState(() {
      _loading = true;
      _error = null;
      _loginRequired = false;
      if (!silent) {
        _code = null;
        _identificationQr = null;
        _identificationExpiresAt = null;
      }
    });
    try {
      final card = widget.source == null
          ? await GetFuelCard(context, silent: silent)
          : await widget.source!.loadCard();
      if (card == null) return;
      final recent = widget.source == null
          ? null
          : await widget.source!.history(widget.now(), 1);
      if (!mounted) return;
      setState(() {
        _card = card;
        _recent = recent?.items.take(3).toList() ?? [];
      });
      if (_foreground && (!silent || _identificationQr == null)) _renewIdentification();
      if (!silent && card.active && _foreground) await _issue();
    } on FuelLoginRequired {
      _refreshTimer?.cancel();
      if (mounted)
        setState(() {
          _card = null;
          _identificationQr = null;
          _recent = [];
          _loginRequired = true;
          _error = falText('يرجى تسجيل الدخول لعرض بطاقة الوقود',
              'Please log in to view your fuel card');
        });
    } catch (_) {
      if (mounted && !silent)
        setState(() => _error = falText('تعذّر تحميل بطاقة الوقود. حاول مجددًا',
            'Unable to load your fuel card. Try again'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _renewIdentification() {
    _identificationQr = null;
    _identificationExpiresAt = null;
    final id = _card?.beneficiaryId;
    if (widget.source != null || !_foreground || id == null || id <= 0) return;
    try {
      final now = widget.now();
      _identificationQr = FuelQrEncryption().encode(id, now: now);
      _identificationExpiresAt = now.add(FuelQrEncryption.lifetime);
    } catch (_) {
      debugPrint('Unable to generate encrypted fuel QR');
    }
  }

  Future<void> _issue() async {
    if (_issuing ||
        widget.source == null ||
        _card?.active != true ||
        !_foreground) return;
    setState(() {
      _issuing = true;
      _code = null;
    });
    try {
      final code = await widget.source!.issueCode();
      if (!mounted || !_foreground) return;
      final duration = code.expiresAt.difference(widget.now());
      if (code.value.isEmpty ||
          duration <= Duration.zero ||
          duration > const Duration(seconds: 31))
        throw StateError('Invalid expiry');
      setState(() {
        _code = code;
        _error = null;
      });
    } catch (_) {
      if (mounted)
        setState(() => _error = falText('تعذّر تجديد الكود. أعد المحاولة',
            'Unable to refresh code. Try again'));
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _card;
    return FalPage(
        title: falText('بطاقتي للوقود', 'My fuel card'),
        body: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  if (_loginRequired)
                    _FuelLoginPrompt(
                        history: false,
                        onLogin: () async {
                          await Navigator.pushNamed(context, loginRoute);
                          if (mounted) await _load();
                        })
                  else if (_loading && card == null)
                    const Padding(
                        padding: EdgeInsets.all(50),
                        child: Center(child: CircularProgressIndicator()))
                  else if (card != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Row(children: [
                        const CircleAvatar(
                            backgroundColor: Color(0xFFFFF5CE),
                            child: Icon(Icons.person_outline, color: falBlue)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(card.name,
                                  style: falStyle(18, weight: FontWeight.w800)),
                              if (card.employeeNumber.isNotEmpty)
                                Text(
                                    '${falText('الرقم الوظيفي', 'Employee number')} ${card.employeeNumber}',
                                    style: falStyle(14))
                            ])),
                        if (card.showStatus)
                          Text(
                              card.active
                                  ? falText('بطاقة نشطة', 'Active')
                                  : falText('بطاقة موقوفة', 'Inactive'),
                              style: falStyle(14,
                                  color: card.active
                                      ? Colors.green.shade700
                                      : Colors.grey))
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [falBlue, falInk]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: LayoutBuilder(builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 290 ||
                            MediaQuery.textScalerOf(context).scale(14) > 21;
                        final balance = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                card.amountBased
                                    ? falText(
                                        'الرصيد المتاح', 'Available balance')
                                    : falText(
                                        'الكمية المتاحة', 'Available fuel'),
                                style: falStyle(14, color: Colors.white70)),
                            Text(
                                '${card.available == null ? '—' : _number(card.available!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}',
                                style: falStyle(28,
                                    color: falGold, weight: FontWeight.w800)),
                            Text(
                                '${falText('من أصل', 'of')} ${card.allowance == null ? '—' : _number(card.allowance!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}',
                                style: falStyle(14, color: Colors.white70)),
                          ],
                        );
                        final fuel = Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0x1AFFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x40FFFFFF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.local_gas_station_outlined,
                                    color: falGold, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: Text(
                                        falText('نوع الوقود', 'Fuel type'),
                                        style: falStyle(14,
                                            color: Colors.white70))),
                              ]),
                              const SizedBox(height: 4),
                              Text(_fuelTypeLabel(card.fuel),
                                  style: falStyle(18,
                                      color: Colors.white,
                                      weight: FontWeight.w800)),
                            ],
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (stacked) ...[
                              balance,
                              const SizedBox(height: 10),
                              fuel
                            ] else
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: balance),
                                    const SizedBox(width: 12),
                                    Expanded(child: fuel),
                                  ]),
                            const SizedBox(height: 8),
                            Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Text(card.period,
                                      style:
                                          falStyle(14, color: Colors.white70)),
                                  Text(
                                      '${falText('المستهلك', 'Used')} ${card.consumedValue == null ? '—' : _number(card.consumedValue!)} ${card.amountBased ? falText('ر.س', 'SAR') : falText('لتر', 'L')}',
                                      style: falStyle(14, color: Colors.white)),
                                ]),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                  value: card.remainingRatio,
                                  minHeight: 7,
                                  color: falGold,
                                  backgroundColor: Colors.white24),
                            ),
                          ],
                        );
                      }),
                    ),
                    if (widget.source == null && _identificationQr != null)
                      _compactFuelCard([
                        LayoutBuilder(builder: (context, constraints) {
                          final qr = QrImageView(
                              key: const ValueKey('fuel-beneficiary-qr'),
                              data: _identificationQr!,
                              size: 180,
                              padding: const EdgeInsets.all(10),
                              backgroundColor: Colors.white);
                          final caption = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(falText('كود التعبئة', 'Refill code'),
                                  style: falStyle(18, weight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(
                                  falText(
                                      'اعرض الكود لموظف المحطة لبدء تعبئة الوقود',
                                      'Show this code to the station attendant to start refilling'),
                                  style: falStyle(14)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFFF5CE),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                    '00:${((_identificationExpiresAt!.difference(widget.now()).inMilliseconds / 1000).ceil()).clamp(0, 30).toString().padLeft(2, '0')}',
                                    style:
                                        falStyle(18, weight: FontWeight.w800)),
                              ),
                            ],
                          );
                          if (constraints.maxWidth < 330 ||
                              MediaQuery.textScalerOf(context).scale(14) > 21) {
                            return Column(children: [
                              qr,
                              const SizedBox(height: 8),
                              caption
                            ]);
                          }
                          return Row(children: [
                            qr,
                            const SizedBox(width: 12),
                            Expanded(child: caption)
                          ]);
                        }),
                      ], color: const Color(0xFFF0F7FD)),
                    if (widget.source == null && _identificationQr == null)
                      _compactFuelCard([
                        Text(
                            falText('تعذّر عرض كود التعريف',
                                'Unable to display identification code'),
                            textAlign: TextAlign.center,
                            style: falStyle(14)),
                      ]),
                    if (widget.source != null)
                      _compactFuelCard([
                        Text(falText('كود التعريف', 'Identification code'),
                            textAlign: TextAlign.center,
                            style: falStyle(20, weight: FontWeight.w800)),
                        Text(
                            falText('اعرض الكود لموظف التعبئة',
                                'Show this code to the station attendant'),
                            textAlign: TextAlign.center,
                            style: falStyle(14)),
                        const SizedBox(height: 10),
                        if (_code != null && seconds > 0 && _foreground)
                          Center(
                              child: QrImageView(
                                  data: _code!.value,
                                  size: 200,
                                  padding: const EdgeInsets.all(20),
                                  backgroundColor: Colors.white))
                        else
                          SizedBox(
                              height: 210,
                              child: Center(
                                  child: _issuing
                                      ? const CircularProgressIndicator()
                                      : Icon(
                                          card.active
                                              ? Icons.qr_code_2
                                              : Icons.lock_outline,
                                          size: 80,
                                          color: Colors.blueGrey))),
                        if (_code != null && seconds > 0)
                          Center(
                              child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox.expand(
                                            child: CircularProgressIndicator(
                                                value: seconds / 30,
                                                strokeWidth: 5,
                                                backgroundColor:
                                                    const Color(0xFFE7EFF6))),
                                        Text(
                                            '00:${seconds.toString().padLeft(2, '0')}',
                                            style: falStyle(17))
                                      ]))),
                        const SizedBox(height: 14),
                        Text(
                            falText('يتجدد تلقائيًا كل ٣٠ ثانية',
                                'Refreshes automatically every 30 seconds'),
                            textAlign: TextAlign.center,
                            style: falStyle(14)),
                        const SizedBox(height: 8),
                        Text(
                            falText('اعرض الكود لموظف المحطة لبدء تعبئة الوقود',
                                'Show this code to the station attendant to start refilling'),
                            textAlign: TextAlign.center,
                            style: falStyle(14, color: falBlue)),
                        OutlinedButton.icon(
                            onPressed: _issuing || !card.active ? null : _issue,
                            icon: const Icon(Icons.refresh),
                            label: Text(falText('تجديد الكود', 'Refresh code')))
                      ]),
                    _compactFuelCard([
                      if (card.vehicle.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fuelSectionTitle(
                                  falText(
                                      'بيانات المركبة', 'Vehicle information'),
                                  Icons.directions_car_outlined),
                              const SizedBox(height: 4),
                              _fuelFields([
                                for (final entry in card.vehicle.entries)
                                  if (entry.value != null &&
                                      entry.value
                                          .toString()
                                          .trim()
                                          .isNotEmpty &&
                                      entry.key != 'id' &&
                                      entry.key != 'fuel_type')
                                    (
                                      _vehicleLabel(entry.key),
                                      '${entry.value}',
                                      entry.key == 'vehicle_number'
                                          ? Icons.pin_outlined
                                          : _vehicleIcon(entry.key)
                                    ),
                              ]),
                            ]),
                      if (card.allowanceDetails.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(
                                  height: 20, color: Color(0xFFDCE7EF)),
                              _fuelSectionTitle(
                                  falText('تفاصيل الرصيد', 'Allowance details'),
                                  Icons.account_balance_wallet_outlined),
                              const SizedBox(height: 4),
                              _fuelFields([
                                if (card.remainingPercentage != null)
                                  (
                                    falText('نسبة الرصيد المتبقي',
                                        'Remaining balance'),
                                    '${_number(card.remainingPercentage!)}%',
                                    Icons.pie_chart_outline
                                  ),
                                if (card.allowanceDetails['period_type'] !=
                                    null)
                                  (
                                    falText('دورية الرصيد', 'Allowance period'),
                                    _periodLabel(
                                        '${card.allowanceDetails['period_type']}'),
                                    Icons.date_range_outlined
                                  ),
                                if (card.allowanceDetails[
                                        'estimated_remaining_volume'] !=
                                    null)
                                  (
                                    falText('الكمية المتبقية تقديريًا (لتر)',
                                        'Estimated remaining fuel (L)'),
                                    _apiNumber(card.allowanceDetails[
                                        'estimated_remaining_volume']),
                                    Icons.local_gas_station_outlined
                                  ),
                                if (card.allowanceDetails[
                                        'estimated_at_unit_price'] !=
                                    null)
                                  (
                                    falText('سعر اللتر التقديري',
                                        'Estimated unit price'),
                                    '${_apiNumber(card.allowanceDetails['estimated_at_unit_price'], decimals: 4)} ${falText('ر.س', 'SAR')}',
                                    Icons.payments_outlined
                                  ),
                              ]),
                            ]),
                      if (card.contract.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(
                                  height: 20, color: Color(0xFFDCE7EF)),
                              _fuelSectionTitle(
                                  falText(
                                      'بيانات العقد', 'Contract information'),
                                  Icons.description_outlined),
                              const SizedBox(height: 4),
                              _fuelFields([
                                if (card.billingName.isNotEmpty)
                                  (
                                    falText('جهة الفوترة', 'Billing customer'),
                                    card.billingName,
                                    Icons.business_outlined
                                  ),
                                if (card.contract['contract_number'] != null)
                                  (
                                    falText('رقم العقد', 'Contract number'),
                                    '${card.contract['contract_number']}',
                                    Icons.tag
                                  ),
                                if (card.contract['starts_on'] != null)
                                  (
                                    falText('بداية العقد', 'Contract starts'),
                                    '${card.contract['starts_on']}',
                                    Icons.event_available_outlined
                                  ),
                                if (card.contract['ends_on'] != null)
                                  (
                                    falText('انتهاء العقد', 'Contract ends'),
                                    '${card.contract['ends_on']}',
                                    Icons.event_outlined
                                  ),
                              ]),
                            ]),
                      const Divider(height: 20, color: Color(0xFFDCE7EF)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(falText('آخر التعبئات', 'Recent refills'),
                                style: falStyle(19, weight: FontWeight.w800)),
                            TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => FuelHistoryPage(
                                            source: widget.source))),
                                child: Text(falText('عرض الكل', 'View all')))
                          ]),
                      if (_recent.isEmpty && card.lastRefill == null)
                        Text(
                            falText(
                                'لا توجد تعبئات سابقة', 'No previous refills'),
                            style: falStyle(14)),
                      if (_recent.isEmpty && card.lastRefill != null)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (card.lastRefill!['station_name'] != null)
                                _cardDetail(
                                    falText('المحطة', 'Station'),
                                    card.lastRefill!['station_name']
                                        .toString()),
                              if (card.lastRefill!['actual_amount'] != null)
                                _cardDetail(
                                    falText(
                                        'قيمة آخر تعبئة', 'Last refill amount'),
                                    '${_apiNumber(card.lastRefill!['actual_amount'])} ${falText('ر.س', 'SAR')}'),
                              if (card.lastRefill!['volume'] != null)
                                _cardDetail(
                                    falText('الكمية (لتر)', 'Volume (L)'),
                                    _apiNumber(card.lastRefill!['volume'])),
                              if (card.lastRefill!['filled_at'] != null)
                                _cardDetail(
                                    falText('تاريخ التعبئة', 'Refill date'),
                                    _refillDate(card.lastRefill!['filled_at'])),
                            ]),
                    ]),
                    ..._recent.map((item) => _movement(context, item)),
                  ],
                  if (!_loading && card == null && _error == null)
                    TextButton(
                        onPressed: _load,
                        child: Text(falText('إعادة المحاولة', 'Retry'))),
                  if (_error != null && !_loginRequired) ...[
                    Text(_error!,
                        style: falStyle(14, color: Colors.red.shade700)),
                    TextButton(
                        onPressed: _load,
                        child: Text(falText('إعادة المحاولة', 'Retry')))
                  ],
                ])));
  }
}

Widget _cardDetail(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(label, style: falStyle(14))),
        const SizedBox(width: 12),
        Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: falStyle(14, weight: FontWeight.w700))),
      ]),
    );
String _apiNumber(dynamic value, {int decimals = 2}) {
  final number = double.tryParse(value.toString());
  return number == null || !number.isFinite
      ? '—'
      : number.toStringAsFixed(decimals);
}

String _periodLabel(String value) =>
    {
      'monthly': falText('شهري', 'Monthly'),
      'weekly': falText('أسبوعي', 'Weekly'),
      'daily': falText('يومي', 'Daily'),
      'yearly': falText('سنوي', 'Yearly'),
    }[value] ??
    value;
String _refillDate(dynamic value) {
  final date = DateTime.tryParse(value.toString());
  if (date == null) return value.toString();
  return '${date.day}/${date.month}/${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _vehicleLabel(String key) =>
    {
      'vehicle_number': falText('رقم المركبة', 'Vehicle number'),
      'vehicle_type': falText('نوع المركبة', 'Vehicle type'),
      'vehicle_model': falText('موديل المركبة', 'Vehicle model'),
      'manufacturing_year': falText('سنة الصنع', 'Manufacturing year'),
      'vehicle_color': falText('اللون', 'Color'),
    }[key] ??
    key;
String _number(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

class FuelMovementDetailsPage extends StatefulWidget {
  const FuelMovementDetailsPage({super.key, required this.movement});
  final FuelMovement movement;
  @override
  State<FuelMovementDetailsPage> createState() =>
      _FuelMovementDetailsPageState();
}

class _FuelMovementDetailsPageState extends State<FuelMovementDetailsPage> {
  late Future<Map<String, dynamic>> _details;
  @override
  void initState() {
    super.initState();
    _details = GetFuelRefillDetails(widget.movement.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return FalPage(
                title: falText('تفاصيل التعبئة', 'Refill details'),
                body: const Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return FalPage(
                title: falText('تفاصيل التعبئة', 'Refill details'),
                body: ListView(padding: const EdgeInsets.all(18), children: [
                  Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      style: falStyle(14, color: Colors.red)),
                  OutlinedButton(
                      onPressed: () => setState(() {
                            _details = GetFuelRefillDetails(widget.movement.id);
                          }),
                      child: Text(falText('إعادة المحاولة', 'Retry'))),
                ]));
          }
          final data = snapshot.data!;
          final movement = _historyFromJson({
            'items': [data]
          }).items.single;
          return _FuelMovementDetailsContent(movement: movement, data: data);
        },
      );
}

class _FuelMovementDetailsContent extends StatelessWidget {
  const _FuelMovementDetailsContent(
      {required this.movement, required this.data});
  final Map<String, dynamic> data;
  final FuelMovement movement;
  Widget _row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(label,
                style: falStyle(14, color: const Color(0xFF718198)))),
        const SizedBox(width: 16),
        Expanded(
            child: Text(value,
                textAlign: TextAlign.end,
                style: falStyle(14, weight: FontWeight.w700))),
      ]));
  String money(double? value) => value == null || !value.isFinite || value < 0
      ? '—'
      : '${value.toStringAsFixed(2)} ${falText('ر.س', 'SAR')}';
  @override
  Widget build(BuildContext context) {
    final m = movement;
    final contract = data['contract'] is Map ? data['contract'] as Map : {};
    final billing = contract['billing_customer'] is Map
        ? contract['billing_customer'] as Map
        : {};
    final allowance = data['allowance'] is Map ? data['allowance'] as Map : {};
    final attachments =
        data['attachments'] is List ? data['attachments'] as List : [];
    return FalPage(
        title: falText('تفاصيل التعبئة', 'Refill details'),
        body: ListView(padding: const EdgeInsets.all(12), children: [
          Center(
              child: Chip(
                  avatar: Icon(
                      m.cancelled ? Icons.cancel_outlined : Icons.check_circle,
                      color: m.cancelled ? Colors.grey : Colors.green.shade700),
                  backgroundColor: m.cancelled
                      ? const Color(0xFFF0F1F3)
                      : const Color(0xFFE9F6ED),
                  side: BorderSide.none,
                  label: Text(
                      m.cancelled
                          ? falText('عملية ملغاة', 'Cancelled transaction')
                          : falText('عملية مكتملة', 'Completed transaction'),
                      style: falStyle(15)))),
          Text(
              '${falText('عملية رقم', 'Transaction')} #${m.operationNumber ?? m.id}',
              textAlign: TextAlign.center,
              style: falStyle(23, weight: FontWeight.w800)),
          Text(
              '${m.date.day}/${m.date.month}/${m.date.year} • ${m.date.hour.toString().padLeft(2, '0')}:${m.date.minute.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: falStyle(14, color: const Color(0xFF718198))),
          const SizedBox(height: 10),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [falBlue, falInk]),
                  borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(falText('كمية الوقود', 'Fuel quantity'),
                          style: falStyle(16, color: Colors.white)),
                      Text('${_number(m.litres)} ${falText('لتر', 'L')}',
                          style: falStyle(32,
                              weight: FontWeight.w800, color: falGold)),
                      Text(m.fuel, style: falStyle(16, color: Colors.white)),
                    ])),
                const Icon(Icons.local_gas_station_outlined,
                    size: 48, color: Color(0xFF86B2D4))
              ])),
          const SizedBox(height: 10),
          if (m.customerName != null)
            _compactFuelCard([
              Row(children: [
                const Icon(Icons.verified_user_outlined,
                    size: 36, color: falBlue),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(falText('تعبئة الوقود', 'Fuel refill'),
                          style: falStyle(15, weight: FontWeight.w800)),
                      Text(
                          falText('لا يوجد مبلغ مستحق عليك',
                              'No payment is due from you'),
                          style: falStyle(13)),
                    ]))
              ])
            ], color: const Color(0xFFECF6FE)),
          _compactFuelCard([
            _fuelSectionTitle(falText('بيانات التعبئة', 'Refill information'),
                Icons.local_gas_station_outlined),
            _row(falText('المحطة', 'Station'), m.station),
            if (m.vehicleNumber != null)
              _row(falText('رقم المركبة', 'Vehicle number'), m.vehicleNumber!),
            if (m.balanceBefore != null)
              _row(falText('الرصيد قبل التعبئة', 'Balance before'),
                  money(m.balanceBefore)),
            if (m.balanceAfter != null)
              _row(falText('الرصيد بعد التعبئة', 'Balance after'),
                  money(m.balanceAfter)),
            if (m.customerName?.isNotEmpty == true) ...[
              const Divider(height: 1),
              _row(falText('العميل', 'Customer'), m.customerName!)
            ],
            if (m.employeeNumber?.isNotEmpty == true) ...[
              const Divider(height: 1),
              _row(falText('الرقم الوظيفي', 'Employee number'),
                  m.employeeNumber!)
            ],
          ]),
          _compactFuelCard([
            _fuelSectionTitle(falText('قيمة التعبئة', 'Refill value'),
                Icons.payments_outlined),
            _row(falText('سعر اللتر وقت التعبئة', 'Unit price at refill'),
                money(m.unitPrice)),
            const Divider(height: 1),
            _row(falText('الكمية', 'Quantity'),
                '${_number(m.litres)} ${falText('لتر', 'L')}'),
            const Divider(color: falGold),
            _row(falText('إجمالي القيمة', 'Total value'), money(m.totalValue)),
            if (m.taxIncluded != null)
              Text(
                  m.taxIncluded!
                      ? falText(
                          'القيمة المعروضة تشمل الضريبة', 'Value includes tax')
                      : falText('القيمة المعروضة لا تشمل الضريبة',
                          'Value excludes tax'),
                  style: falStyle(14, color: const Color(0xFF718198))),
            if (m.totalValue == null && m.unitPrice == null)
              Text(
                  falText('لم تُرسل بيانات القيمة لهذه الحركة',
                      'Price information was not provided for this transaction'),
                  style: falStyle(14, color: const Color(0xFF718198))),
          ]),
          if (contract.isNotEmpty)
            _compactFuelCard([
              _fuelSectionTitle(falText('بيانات العقد', 'Contract information'),
                  Icons.description_outlined),
              if (contract['contract_number'] != null)
                _row(falText('رقم العقد', 'Contract number'),
                    contract['contract_number'].toString()),
              if (billing['name'] != null)
                _row(falText('جهة الفوترة', 'Billing customer'),
                    billing['name'].toString()),
            ]),
          if (allowance.isNotEmpty)
            _compactFuelCard([
              _fuelSectionTitle(falText('فترة الرصيد', 'Allowance period'),
                  Icons.date_range_outlined),
              if (allowance['period_type'] != null)
                _row(falText('الدورية', 'Period'),
                    _periodLabel(allowance['period_type'].toString())),
              if (allowance['starts_on'] != null)
                _row(falText('من', 'From'), allowance['starts_on'].toString()),
              if (allowance['ends_on'] != null)
                _row(falText('إلى', 'To'), allowance['ends_on'].toString()),
            ]),
          if (attachments.isNotEmpty)
            _compactFuelCard([
              _fuelSectionTitle(falText('صور التعبئة', 'Refill attachments'),
                  Icons.photo_library_outlined),
              ...attachments
                  .whereType<Map>()
                  .where((attachment) => attachment['url'] != null)
                  .map((attachment) {
                final url = attachment['url'].toString();
                final label = attachment['kind'] == 'dispenser'
                    ? falText('صورة المضخة', 'Dispenser photo')
                    : attachment['kind'] == 'meter'
                        ? falText('صورة العداد', 'Meter photo')
                        : falText('صورة مرفقة', 'Attachment');
                return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(label,
                              style: falStyle(14, weight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          InkWell(
                              onTap: () => showDialog<void>(
                                  context: context,
                                  builder: (context) => Dialog(
                                          child: Stack(children: [
                                        InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 5,
                                            child: Image.network(url,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, error,
                                                        stack) =>
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(24),
                                                        child: Text(falText(
                                                            'تعذّر تحميل الصورة',
                                                            'Unable to load image'))))),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: const Icon(Icons.close))),
                                      ]))),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child,
                                            progress) =>
                                        progress == null
                                            ? child
                                            : const SizedBox(
                                                height: 180,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator())),
                                    errorBuilder: (_, error, stack) => SizedBox(
                                        height: 100,
                                        child: Center(
                                            child: Text(
                                                falText('تعذّر تحميل الصورة',
                                                    'Unable to load image'),
                                                style: falStyle(13)))),
                                  ))),
                        ]));
              }),
            ]),
          OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(falText('الرجوع للحركات', 'Back to history'))),
        ]));
  }
}

Widget _movement(BuildContext context, FuelMovement item) => InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FuelMovementDetailsPage(movement: item))),
    child: falCard([
      Row(children: [
        const CircleAvatar(
            backgroundColor: Color(0xFFECF5FC),
            child: Icon(Icons.local_gas_station_outlined, color: falBlue)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.station, style: falStyle(14, weight: FontWeight.w800)),
          Text(
              '${item.date.day}/${item.date.month}/${item.date.year} • ${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}',
              style: falStyle(11)),
          Text('${item.fuel} • #${item.operationNumber ?? item.id}',
              style: falStyle(11))
        ])),
        const SizedBox(width: 8),
        Column(children: [
          Text('${_number(item.litres)} ${falText('لتر', 'L')}',
              style: falStyle(20, weight: FontWeight.w800)),
          Text(
              item.cancelled
                  ? falText('ملغاة', 'Cancelled')
                  : falText('مكتملة', 'Completed'),
              style: falStyle(11,
                  color: item.cancelled ? Colors.grey : Colors.green.shade700))
        ])
      ])
    ]));

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
  bool _loginRequired = false;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_busy && !reset) return;
    final request = ++_request;
    final page = reset ? 1 : _page + 1;
    setState(() {
      _busy = true;
      _error = null;
      _loginRequired = false;
      if (reset) {
        _items.clear();
        _summary = null;
        _more = false;
      }
    });
    try {
      final history = widget.source != null
          ? await widget.source!.history(_month, page)
          : _historyFromJson(await GetFuelRefills(
              _month,
              page,
              _filter == 0
                  ? null
                  : _filter == 1
                      ? 'completed'
                      : 'cancelled'));
      if (!mounted || request != _request) return;
      setState(() {
        _items.addAll(history.items);
        _summary = history;
        _page = page;
        _more = history.hasMore;
      });
    } on FuelLoginRequired {
      if (mounted && request == _request)
        setState(() {
          _items.clear();
          _summary = null;
          _more = false;
          _page = 0;
          _loginRequired = true;
          _error = falText('يرجى تسجيل الدخول لعرض حركات الوقود',
              'Please log in to view your fuel history');
        });
    } catch (e) {
      if (mounted && request == _request)
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FalPage(
      title: falText('حركات الوقود', 'Fuel history'),
      body: RefreshIndicator(
          onRefresh: () => _load(reset: true),
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(18),
              children: [
                if (_loginRequired)
                  _FuelLoginPrompt(
                      history: true,
                      onLogin: () async {
                        await Navigator.pushNamed(context, loginRoute);
                        if (mounted) await _load(reset: true);
                      })
                else ...[
                  Text(
                      falText('تابع تعبئاتك السابقة',
                          'Track your previous refills'),
                      style: falStyle(15)),
                  const SizedBox(height: 16),
                  ...[
                    falCard([
                      Text(falText('إجمالي هذا الشهر', 'Monthly total'),
                          style: falStyle(14)),
                      Text(
                          '${_summary?.totalLitres == null ? '—' : _number(_summary!.totalLitres!)} ${falText('لتر', 'L')}',
                          style: falStyle(30, weight: FontWeight.w800)),
                      if (_summary?.totalAmount != null)
                        Text(
                            '${_number(_summary!.totalAmount!)} ${falText('ر.س', 'SAR')}',
                            style: falStyle(20, weight: FontWeight.w800)),
                      Text(
                          '${_summary?.totalCount ?? '—'} ${falText('عمليات', 'transactions')}',
                          style: falStyle(13))
                    ], color: const Color(0xFFECF6FE)),
                    OutlinedButton.icon(
                        onPressed: () async {
                          final chosen = await showDatePicker(
                              context: context,
                              initialDate: _month,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now());
                          if (chosen != null && mounted) {
                            setState(() =>
                                _month = DateTime(chosen.year, chosen.month));
                            _load(reset: true);
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text('${_month.month} / ${_month.year}')),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                        segments: [
                          ButtonSegment(
                              value: 0, label: Text(falText('الكل', 'All'))),
                          ButtonSegment(
                              value: 1,
                              label: Text(falText('مكتملة', 'Completed'))),
                          ButtonSegment(
                              value: 2,
                              label: Text(falText('ملغاة', 'Cancelled')))
                        ],
                        selected: {
                          _filter
                        },
                        onSelectionChanged: (v) {
                          setState(() => _filter = v.first);
                          _load(reset: true);
                        }),
                    const SizedBox(height: 16),
                    ..._items
                        .where((i) =>
                            _filter == 0 || (_filter == 2) == i.cancelled)
                        .map((item) => _movement(context, item)),
                    if (!_busy &&
                        _error == null &&
                        !_items.any((i) =>
                            _filter == 0 || (_filter == 2) == i.cancelled))
                      Text(
                          falText('لا توجد حركات مطابقة',
                              'No matching transactions'),
                          style: falStyle(14)),
                    if (_busy) const Center(child: CircularProgressIndicator()),
                    if (_error != null)
                      Text(_error!, style: falStyle(14, color: Colors.red)),
                    if (_error != null || _more)
                      OutlinedButton(
                          onPressed:
                              _busy ? null : () => _load(reset: _page == 0),
                          child: Text(_error != null
                              ? falText('إعادة المحاولة', 'Retry')
                              : falText('عرض المزيد', 'Load more'))),
                  ],
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
      station: item['station'] is Map
          ? item['station']['name']?.toString() ?? ''
          : '',
      vehicleNumber: item['vehicle'] is Map
          ? item['vehicle']['vehicle_number']?.toString()
          : null,
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
  final current =
      int.tryParse(pagination['current_page']?.toString() ?? '') ?? 1;
  final last =
      int.tryParse(pagination['last_page']?.toString() ?? '') ?? current;
  return FuelHistory(items,
      hasMore: current < last,
      totalLitres: number(summary['total_volume']),
      totalAmount: number(summary['total_amount']),
      totalCount: int.tryParse(summary['operations_count']?.toString() ?? ''));
}

class _FuelLoginPrompt extends StatelessWidget {
  const _FuelLoginPrompt({required this.history, required this.onLogin});
  final bool history;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FD),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Image.asset('lib/assets/services_art.png',
                    width: 380,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true),
              ),
              const SizedBox(height: 26),
              Text(
                  falText(
                      history
                          ? 'كل تعبئاتك في مكان واحد'
                          : 'بطاقتك… لتعبئة أسهل',
                      history
                          ? 'All your refills in one place'
                          : 'Your card for easier refills'),
                  textAlign: TextAlign.center,
                  style: falStyle(23, weight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                  falText(
                      history
                          ? 'تابع حركات الوقود، وراجع تفاصيل التعبئات وإجمالي استهلاكك الشهري من حسابك.'
                          : 'اعرض رصيدك المتاح وبيانات مركبتك، واستخدم كود بطاقتك عند تعبئة الوقود في المحطة.',
                      history
                          ? 'Track your fuel transactions, refill details and monthly consumption from your account.'
                          : 'View your available balance and vehicle details, and show your card code when refilling at the station.'),
                  textAlign: TextAlign.center,
                  style: falStyle(14, color: Color(0xFF60788D))),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FD),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.lock_outline, color: falBlue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          falText(
                              history
                                  ? 'يرجى تسجيل الدخول لعرض حركات الوقود'
                                  : 'يرجى تسجيل الدخول لعرض بطاقة الوقود',
                              history
                                  ? 'Please log in to view your fuel history'
                                  : 'Please log in to view your fuel card'),
                          style: falStyle(13))),
                ]),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child:
                      falButton(falText('تسجيل الدخول', 'Sign in'), onLogin)),
            ]),
          ),
        ),
      );
}

String _fuelTypeLabel(String fuel) {
  final value = fuel.trim();
  if (value.isEmpty) return '—';
  if (value == '91' || value == '95' || value == '98') {
    return '${falText('بنزين', 'Gasoline')} $value';
  }
  return value;
}

IconData _vehicleIcon(String key) =>
    {
      'vehicle_type': Icons.directions_car_outlined,
      'vehicle_model': Icons.auto_awesome_outlined,
      'manufacturing_year': Icons.calendar_month_outlined,
      'vehicle_color': Icons.palette_outlined,
    }[key] ??
    Icons.info_outline;

Widget _fuelSectionTitle(String title, IconData icon) => Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF5CE),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: falBlue, size: 21),
      ),
      const SizedBox(width: 8),
      Expanded(
          child: Text(title, style: falStyle(18, weight: FontWeight.w800))),
    ]);

Widget _fuelFields(List<(String, String, IconData)> fields) =>
    LayoutBuilder(builder: (context, constraints) {
      final single = constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(14) > 21;
      return Wrap(spacing: 16, runSpacing: 0, children: [
        for (final field in fields)
          SizedBox(
            width: single ||
                    field.$3 == Icons.tag ||
                    field.$3 == Icons.business_outlined
                ? constraints.maxWidth
                : (constraints.maxWidth - 16) / 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(field.$3, color: falBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(field.$1,
                          style: falStyle(14, color: const Color(0xFF526C82))),
                      Text(field.$2,
                          style: falStyle(16, weight: FontWeight.w800)),
                    ])),
              ]),
            ),
          ),
      ]);
    });

Widget _compactFuelCard(List<Widget> children, {Color color = Colors.white}) =>
    Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0xFFD2E3F0)),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
