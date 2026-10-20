import 'package:flutter/material.dart';
import '../Models/ServicesModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/FalDesign.dart';

class ServicesDetailsPage extends StatefulWidget {
  const ServicesDetailsPage({super.key, required this.obj});
  final List<ServicesModel> obj;
  @override
  State<ServicesDetailsPage> createState() => _ProductState();
}
class _ProductState extends State<ServicesDetailsPage> {
  final Map<ServicesDetailsModel, TextEditingController> _controllers = {};
  ServicesModel? get _service => widget.obj.where((service) => service.selected == true).firstOrNull;
  @override
  void initState() {
    super.initState();
    for (final item in _service?.details ?? <ServicesDetailsModel>[]) {
      _controllers[item] = TextEditingController(text: item.quantity != null && item.quantity! > 0 ? normalizeCartNumber(item.quantity.toString()) : '1');
    }
  }
  @override
  void dispose() { for (final controller in _controllers.values) { controller.dispose(); } super.dispose(); }
  void _step(ServicesDetailsModel item, double step) {
    final quantity = ((cartQuantity(_controllers[item]!.text) ?? 1) + step).clamp(1.0, double.infinity);
    _controllers[item]!.text = quantity == quantity.roundToDouble() ? quantity.toInt().toString() : quantity.toString();
    _change(item, _controllers[item]!.text);
  }
  void _change(ServicesDetailsModel item, String raw) {
    setState(() {
      item.quantity = cartQuantity(raw);
      if (item.selected == true && !validCartItem(item)) item.selected = false;
      ServicesData.serviceData = widget.obj;
    });
  }
  void _toggle(ServicesDetailsModel item) {
    final quantity = cartQuantity(_controllers[item]!.text);
    item.quantity = quantity;
    if (!validCartItem(item)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('أدخل كمية صحيحة أكبر من صفر', 'Enter a valid quantity greater than zero'))));
      return;
    }
    setState(() { item.selected = item.selected != true; ServicesData.serviceData = widget.obj; });
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('خيارات الخدمة', 'Service options'),
    bottom: Column(mainAxisSize: MainAxisSize.min, children: [Row(children: [Expanded(child: Text(falText('الإجمالي', 'Total'), style: falStyle(14))),
      Text('${cartTotal(widget.obj).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}', textDirection: TextDirection.ltr, style: falStyle(20, weight: FontWeight.w800))]),
      const SizedBox(height: 10), falButton(falText('عرض السلة', 'View cart'), validCart(widget.obj) ? () async {
        await Navigator.pushNamed(context, serviceSelectedPageRoute, arguments: widget.obj);
        if (mounted) setState(() {});
      } : null)]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(_service?.name ?? falText('اختر خدمة أولاً', 'Choose a service first'), style: falStyle(25, weight: FontWeight.w800)),
      const SizedBox(height: 8), Text(falText('اختر الخدمات وحدّد الكمية المطلوبة', 'Choose the items and quantities you need'), style: falStyle(13, weight: FontWeight.w400)), const SizedBox(height: 24),
      if (_service == null || _service!.details.isEmpty) falCard([const Icon(Icons.inventory_2_outlined, color: falBlue, size: 48), const SizedBox(height: 14),
        Text(falText('لا توجد خيارات متاحة لهذه الخدمة حاليًا', 'No options are currently available for this service'), textAlign: TextAlign.center, style: falStyle(15))], color: const Color(0xFFEEF6FC)),
      for (final item in _service?.details ?? <ServicesDetailsModel>[]) falCard([
        Row(children: [Expanded(child: Text(item.name ?? '', style: falStyle(19, weight: FontWeight.w800))),
          if (item.selected == true) const Icon(Icons.check_circle, color: falBlue)]),
        const SizedBox(height: 8), Text(item.price == null || !item.price!.isFinite || item.price! < 0 ? falText('السعر غير متاح', 'Price unavailable')
          : '${item.price!.toStringAsFixed(2)} ${falText('ر.س', 'SAR')}', style: falStyle(19, weight: FontWeight.w800)),
        const SizedBox(height: 16), Row(children: [Text(falText('الكمية', 'Quantity'), style: falStyle(14)), const SizedBox(width: 12),
          IconButton(tooltip: falText('زيادة الكمية', 'Increase quantity'), onPressed: () => _step(item, 1), icon: const Icon(Icons.add_circle_outline, color: falBlue)),
          Expanded(child: TextField(controller: _controllers[item], keyboardType: const TextInputType.numberWithOptions(decimal: true), textDirection: TextDirection.ltr, textAlign: TextAlign.center,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)), onChanged: (value) => _change(item, value))),
          IconButton(tooltip: falText('تقليل الكمية', 'Decrease quantity'), onPressed: () => _step(item, -1), icon: const Icon(Icons.remove_circle_outline, color: falBlue)),
        ]), const SizedBox(height: 16), OutlinedButton(onPressed: item.price == null || !item.price!.isFinite || item.price! < 0 ? null : () => _toggle(item),
          child: Text(item.selected == true ? falText('إزالة من السلة', 'Remove from cart') : falText('إضافة للسلة', 'Add to cart'))),
      ], color: item.selected == true ? const Color(0xFFEEF6FC) : Colors.white),
    ]));
}
