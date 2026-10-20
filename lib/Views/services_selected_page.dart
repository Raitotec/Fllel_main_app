import 'package:flutter/material.dart';
import '../Models/ServicesModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/ServicesData.dart';
import '../Shared_View/FalDesign.dart';

class ServicesSelectedPage extends StatefulWidget {
  const ServicesSelectedPage({super.key, required this.obj});
  final List<ServicesModel> obj;
  @override
  State<ServicesSelectedPage> createState() => _CartState();
}
class _CartState extends State<ServicesSelectedPage> {
  void _change(ServicesDetailsModel item, double delta) => setState(() {
    final quantity = (item.quantity ?? 1) + delta;
    if (quantity > 0 && quantity.isFinite && ((item.price ?? 0) * quantity).isFinite) item.quantity = quantity;
    ServicesData.serviceData = widget.obj;
  });
  Future<void> _continue() async {
    if (!validCart(widget.obj)) return;
    if ((DelegateData.delegateData?.id ?? -1) <= 0) {
      await Navigator.pushNamed(context, loginRoute);
      return;
    }
    ServicesData.serviceData = widget.obj;
    await Navigator.pushNamed(context, PayPageRoute, arguments: widget.obj);
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final items = cartItems(widget.obj).toList();
    return FalPage(title: falText('السلة', 'Cart'),
      bottom: falButton(falText('متابعة الطلب', 'Continue order'), validCart(widget.obj) ? _continue : null),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(falText('راجع خدماتك', 'Review your services'), style: falStyle(25, weight: FontWeight.w800)), const SizedBox(height: 22),
        if (items.isEmpty) falCard([const Icon(Icons.shopping_bag_outlined, color: falBlue, size: 58), const SizedBox(height: 16),
          Text(falText('السلة فارغة', 'Your cart is empty'), textAlign: TextAlign.center, style: falStyle(20, weight: FontWeight.w800)),
          const SizedBox(height: 8), Text(falText('أضف الخدمات التي تحتاجها لبدء الطلب', 'Add the services you need to start your order'), textAlign: TextAlign.center, style: falStyle(13, weight: FontWeight.w400))], color: const Color(0xFFEEF6FC)),
        for (final service in widget.obj) for (final item in service.details.where((item) => item.selected == true)) falCard([
          Row(children: [Expanded(child: Text(item.name ?? '', style: falStyle(19, weight: FontWeight.w800))),
            IconButton(tooltip: falText('حذف من السلة', 'Remove from cart'), onPressed: () => setState(() { item.selected = false; ServicesData.serviceData = widget.obj; }),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFB42318)))]),
          Text(service.name ?? '', style: falStyle(12, weight: FontWeight.w400)), const SizedBox(height: 18),
          Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(falText('سعر الوحدة', 'Unit price'), style: falStyle(12)),
            Text('${(item.price ?? 0).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}', style: falStyle(16, weight: FontWeight.w800))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(falText('المجموع الفرعي', 'Subtotal'), style: falStyle(12)),
              Text(validCartItem(item) ? '${(item.price! * item.quantity!).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}' : falText('كمية أو سعر غير صالح', 'Invalid quantity or price'), style: falStyle(16, weight: FontWeight.w800))]))]),
          const SizedBox(height: 14), Row(children: [Text(falText('الكمية', 'Quantity'), style: falStyle(14)), const Spacer(),
            IconButton(tooltip: falText('زيادة الكمية', 'Increase quantity'), onPressed: () => _change(item, 1), icon: const Icon(Icons.add_circle_outline, color: falBlue)),
            Text('${item.quantity ?? 0}', style: falStyle(17, weight: FontWeight.w800)),
            IconButton(tooltip: falText('تقليل الكمية', 'Decrease quantity'), onPressed: () => _change(item, -1), icon: const Icon(Icons.remove_circle_outline, color: falBlue))]),
        ]),
        if (items.isNotEmpty) falCard([Row(children: [Expanded(child: Text(falText('الإجمالي', 'Total'), style: falStyle(19, weight: FontWeight.w800))),
          Text('${cartTotal(widget.obj).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}', textDirection: TextDirection.ltr, style: falStyle(22, weight: FontWeight.w800))]),
          const SizedBox(height: 12), Container(height: 3, color: falGold)], color: const Color(0xFFEEF6FC)),
        OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.add), label: Text(falText('إضافة خدمات أخرى', 'Add more services'))),
      ]));
  }
}
