import 'package:flutter/material.dart';
import '../Api/SetvicesApi.dart';
import '../Models/OrderModel.dart';
import '../Models/ServicesModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_Data/formatDateTime.dart';
import '../Shared_View/FalDesign.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key, required this.obj, this.submitOrder});
  final List<ServicesModel> obj;
  final Future<String?> Function(BuildContext, OrderModel)? submitOrder;
  @override
  State<PayPage> createState() => _CheckoutState();
}
class _CheckoutState extends State<PayPage> {
  final _form = GlobalKey<FormState>();
  final _address = TextEditingController();
  bool _sending = false;
  String? get _type => widget.obj.where((service) => service.details.any((item) => item.selected == true)).firstOrNull?.type;
  @override
  void dispose() { _address.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (_sending || !validCart(widget.obj) || !_form.currentState!.validate()) return;
    if ((DelegateData.delegateData?.id ?? -1) <= 0) { await Navigator.pushNamed(context, loginRoute); return; }
    final order = OrderModel(status: 'underexecute', customerId: DelegateData.delegateData!.id.toString(),
      totalCost: cartTotal(widget.obj).toStringAsFixed(2), date: getFormatDate(DateTime.now()), inStation: _type,
      address: _address.text.trim(), details: cartItems(widget.obj).map((item) => DetailsOrderModel(
        productId: item.id.toString(), quantity: item.quantity.toString(), cost: item.price.toString())).toList());
    setState(() => _sending = true);
    try {
      final result = await (widget.submitOrder ?? AddOrder)(context, order);
      if (!mounted) return;
      if (result != null && result.isNotEmpty) {
        for (final item in cartItems(widget.obj).toList()) { item.selected = false; }
        await Navigator.pushReplacementNamed(context, RatePageRoute, arguments: result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('لم يتم تأكيد الطلب. أعد المحاولة.', 'The order was not confirmed. Please try again.'))));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر إرسال الطلب', 'Unable to send the order'))));
    } finally { if (mounted) setState(() => _sending = false); }
  }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('إتمام الطلب', 'Checkout'), loading: _sending,
    bottom: Column(mainAxisSize: MainAxisSize.min, children: [falButton(falText('تأكيد الطلب', 'Confirm order'), !_sending && validCart(widget.obj) ? _submit : null),
      const SizedBox(height: 8), Text(falText('راجع بياناتك قبل التأكيد', 'Review your information before confirming'), style: falStyle(11, weight: FontWeight.w400))]),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
      falCard([Text(falText('ملخص الطلب', 'Order summary'), style: falStyle(20, weight: FontWeight.w800)), const SizedBox(height: 16),
        for (final item in cartItems(widget.obj)) Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.name ?? '', style: falStyle(15, weight: FontWeight.w800)),
            Text('${falText('الكمية', 'Quantity')}: ${item.quantity ?? 0}', style: falStyle(12, weight: FontWeight.w400))])),
          Text(validCartItem(item) ? '${(item.price! * item.quantity!).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}' : falText('غير صالح', 'Invalid'), style: falStyle(15)),
        ])), const Divider(color: Color(0xFFD2E3F0)), Row(children: [Expanded(child: Text(falText('الإجمالي', 'Total'), style: falStyle(18, weight: FontWeight.w800))),
          Text('${cartTotal(widget.obj).toStringAsFixed(2)} ${falText('ر.س', 'SAR')}', textDirection: TextDirection.ltr, style: falStyle(21, weight: FontWeight.w800))]),
      ]),
      if (_type == '0') falCard([Text(falText('عنوان الخدمة', 'Service address'), style: falStyle(19, weight: FontWeight.w800)), const SizedBox(height: 16),
        TextFormField(controller: _address, minLines: 2, maxLines: 4, keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(hintText: falText('الحي، الشارع، رقم المبنى', 'District, street, building number'), prefixIcon: const Icon(Icons.location_on_outlined, color: falBlue)),
          validator: (value) => (value ?? '').trim().isEmpty ? falText('أدخل عنوان الخدمة', 'Enter the service address') : null),
      ]),
      falCard([Text(falText('طريقة الدفع', 'Payment method'), style: falStyle(19, weight: FontWeight.w800)), const SizedBox(height: 18),
        Row(children: [const Icon(Icons.payments_outlined, color: falBlue, size: 38), const SizedBox(width: 14),
          Expanded(child: Text(falText('نقدًا', 'Cash'), style: falStyle(18, weight: FontWeight.w800))), const Icon(Icons.check_circle, color: falBlue)]),
        const SizedBox(height: 10), Text(falText('الدفع النقدي هو الخيار المتاح حاليًا', 'Cash is the currently available payment option'), style: falStyle(13, weight: FontWeight.w400)),
      ], color: const Color(0xFFEEF6FC)),
      if (!validCart(widget.obj)) Text(falText('السلة فارغة أو تحتوي بيانات غير صالحة', 'The cart is empty or contains invalid information'), style: falStyle(14)),
    ])));
}
