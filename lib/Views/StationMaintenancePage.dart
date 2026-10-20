import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../Api/MaintenanceApi.dart';
import '../Models/MaintenanceModel.dart';
import '../Routes/route_constants.dart';
import '../Shared_Data/CartData.dart';
import '../Shared_Data/DelegateData.dart';
import '../Shared_View/FalDesign.dart';
import '../Shared_View/FalField.dart';

class MaintenanceRequest {
  const MaintenanceRequest(this.phone, this.station, this.serviceId, this.address, this.comment, this.imagePaths);
  final String phone, station, serviceId, address, comment;
  final List<String> imagePaths;
}
class StationMaintenancePage extends StatefulWidget {
  const StationMaintenancePage({super.key, this.loadServices, this.submitRequest});
  final Future<List<MaintenanceModel>?> Function(BuildContext)? loadServices;
  final Future<bool?> Function(BuildContext, MaintenanceRequest)? submitRequest;
  @override
  State<StationMaintenancePage> createState() => _MaintenanceState();
}
class _MaintenanceState extends State<StationMaintenancePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _phone = TextEditingController(), _station = TextEditingController(), _address = TextEditingController(), _notes = TextEditingController();
  List<MaintenanceModel>? _services;
  MaintenanceModel? _service;
  String? _image;
  bool _loading = true, _sending = false, _picking = false;
  @override
  void initState() {
    super.initState();
    _name.text = DelegateData.delegateData?.name ?? '';
    _phone.text = DelegateData.delegateData?.mobile ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _load(); });
  }
  Future<void> _load() async {
    setState(() => _loading = true);
    List<MaintenanceModel>? result;
    try { result = await (widget.loadServices ?? GetMaintenanceServices)(context); } catch (_) { result = null; }
    if (mounted) setState(() { _services = result; _service = null; _loading = false; });
  }
  Future<void> _pick() async {
    if (_picking || _sending) return;
    setState(() => _picking = true);
    try {
      final selected = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selected == null || !mounted) return;
      final target = '${File(selected.path).parent.path}/fal-maintenance-${DateTime.now().microsecondsSinceEpoch}.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(selected.path, target, quality: 65, format: CompressFormat.jpeg);
      if (mounted) setState(() => _image = compressed?.path ?? selected.path);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر إرفاق الصورة', 'Unable to attach the image'))));
    } finally { if (mounted) setState(() => _picking = false); }
  }
  Future<void> _submit() async {
    if (_sending || _picking || !_form.currentState!.validate() || _service?.id == null) return;
    final request = MaintenanceRequest(normalizeCartNumber(_phone.text), _station.text.trim(), _service!.id.toString(), _address.text.trim(),
      '${falText('الاسم', 'Name')}: ${_name.text.trim()}\n${_notes.text.trim()}', _image == null ? [] : [_image!]);
    setState(() => _sending = true);
    try {
      final result = widget.submitRequest == null ? await SaveMaintenanceServices(context, request.phone, request.station, request.serviceId, request.address, '', '', request.comment, request.imagePaths)
        : await widget.submitRequest!(context, request);
      if (mounted && result == true) Navigator.pushNamedAndRemoveUntil(context, homeRoute, (_) => false);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(falText('تعذّر إرسال طلب الصيانة', 'Unable to send the maintenance request'))));
    } finally { if (mounted) setState(() => _sending = false); }
  }
  @override
  void dispose() { for (final controller in [_name, _phone, _station, _address, _notes]) { controller.dispose(); } super.dispose(); }
  @override
  Widget build(BuildContext context) => FalPage(title: falText('صيانة المحطة', 'Station maintenance'), loading: _loading || _sending || _picking,
    bottom: falButton(falText('إرسال طلب الصيانة', 'Send maintenance request'), _services == null || _services!.isEmpty || _loading || _sending || _picking ? null : _submit),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, children: [
      falCard([const Icon(Icons.handyman_outlined, color: falBlue, size: 42), const SizedBox(height: 8), Text(falText('كيف نقدر نخدم محطتك؟', 'How can we help your station?'), textAlign: TextAlign.center, style: falStyle(20, weight: FontWeight.w800))], color: const Color(0xFFEEF6FC)),
      Text(falText('نوع الصيانة', 'Maintenance service'), style: falStyle(18, weight: FontWeight.w800)), const SizedBox(height: 14),
      DropdownButtonFormField<MaintenanceModel>(key: ValueKey(_services), initialValue: _service, isExpanded: true,
        decoration: InputDecoration(labelText: falText('اختر الخدمة', 'Choose a service')),
        items: (_services ?? []).map((item) => DropdownMenuItem(value: item, child: Text(item.name ?? '', style: falStyle(14)))).toList(),
        onChanged: (value) => setState(() => _service = value), validator: (value) => value?.id == null ? falText('اختر خدمة الصيانة', 'Choose a maintenance service') : null),
      if (!_loading && (_services == null || _services!.isEmpty)) ...[const SizedBox(height: 10), Text(falText('لا توجد خدمات صيانة متاحة حاليًا', 'No maintenance services are currently available'), style: falStyle(13)), TextButton(onPressed: _load, child: Text(falText('إعادة المحاولة', 'Try again')))],
      const SizedBox(height: 26), Text(falText('بيانات التواصل', 'Contact information'), style: falStyle(18, weight: FontWeight.w800)), const SizedBox(height: 16),
      FalField(controller: _name, label: falText('الاسم', 'Name'), icon: Icons.person_outline), FalField(controller: _phone, label: falText('رقم الجوال', 'Mobile number'), icon: Icons.phone_outlined, phone: true),
      const SizedBox(height: 8), Text(falText('بيانات المحطة', 'Station information'), style: falStyle(18, weight: FontWeight.w800)), const SizedBox(height: 16),
      FalField(controller: _station, label: falText('اسم المحطة', 'Station name'), icon: Icons.local_gas_station_outlined),
      FalField(controller: _address, label: falText('عنوان المحطة', 'Station address'), icon: Icons.location_on_outlined),
      FalField(controller: _notes, label: falText('وصف المشكلة (اختياري)', 'Describe the issue (optional)'), icon: Icons.chat_bubble_outline, optional: true, lines: 3),
      if (_image != null) Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(_image!), height: 160, width: double.infinity, fit: BoxFit.cover)),
        Positioned(top: 8, left: 8, child: IconButton.filled(tooltip: falText('إزالة الصورة', 'Remove image'), onPressed: () => setState(() => _image = null), icon: const Icon(Icons.close)))]),
      OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.add_photo_alternate_outlined), label: Text(falText('إضافة صورة للمشكلة (اختياري)', 'Attach an image (optional)'))),
      const SizedBox(height: 12),
    ])));
}
