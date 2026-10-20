import 'package:flutter/material.dart';
import '../Shared_Data/CartData.dart';
import 'FalDesign.dart';

class FalField extends StatelessWidget {
  const FalField({super.key, required this.controller, required this.label, required this.icon, this.phone = false, this.optional = false, this.lines = 1, this.onChanged});
  final ValueChanged<String>? onChanged;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool phone, optional;
  final int lines;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 18), child: TextFormField(controller: controller,
    keyboardType: phone ? TextInputType.phone : lines > 1 ? TextInputType.multiline : TextInputType.text,
    textDirection: phone ? TextDirection.ltr : null, minLines: lines, maxLines: lines > 1 ? lines + 2 : 1,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: falBlue), alignLabelWithHint: lines > 1),
    onChanged: onChanged, validator: (raw) {
      final value = (raw ?? '').trim();
      if (optional && value.isEmpty) return null;
      if (value.isEmpty) return falText('هذا الحقل مطلوب', 'This field is required');
      if (phone && !RegExp(r'^05[0-9]{8}$').hasMatch(normalizeCartNumber(value))) return falText('أدخل رقم جوال صحيحًا يبدأ بـ05', 'Enter a valid number starting with 05');
      return null;
    }));
}
