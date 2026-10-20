import '../Models/ServicesModel.dart';

String normalizeCartNumber(String raw) {
  const digits = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
  var value = raw.trim().replaceAll('٫', '.');
  for (var i = 0; i < digits.length; i++) { value = value.replaceAll(digits[i], '${i % 10}'); }
  return value;
}
double? cartQuantity(String raw) {
  final value = normalizeCartNumber(raw);
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) return null;
  final quantity = double.tryParse(value);
  return quantity != null && quantity.isFinite && quantity > 0 ? quantity : null;
}
Iterable<ServicesDetailsModel> cartItems(List<ServicesModel> services) => services.expand((service) => service.details).where((item) => item.selected == true);
bool validCartItem(ServicesDetailsModel item) => item.id != null && item.price != null && item.price!.isFinite && item.price! >= 0 && item.quantity != null && item.quantity!.isFinite && item.quantity! > 0 && (item.price! * item.quantity!).isFinite;
bool validCart(List<ServicesModel> services) => cartItems(services).isNotEmpty && cartItems(services).every(validCartItem) && cartTotal(services).isFinite;
double cartTotal(List<ServicesModel> services) => cartItems(services).where(validCartItem).fold(0.0, (sum, item) => sum + item.price! * item.quantity!);
