import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../Shared_Data/LanguageData.dart';
import '../ViewModels/ConnectUsViewModel.dart';

class ConnectUsPage extends StatelessWidget {
  const ConnectUsPage({super.key, this.initialMessage = '', this.initialMobile});
  final String initialMessage;
  final String? initialMobile;
  String t(String ar, String en) => LanguageData.languageData == 'ar' ? ar : en;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) {
      final vm = ConnectUsViewModel()..init(context);
      vm.commentController.text = initialMessage;
      if (initialMobile != null) vm.mobileController.text = initialMobile!;
      return vm;
    },
    child: Consumer<ConnectUsViewModel>(builder: (context, vm, _) => Theme(
      data: Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Cairo'),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1C6096))),
      child: Scaffold(backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white,
          foregroundColor: const Color(0xFF123D63), elevation: 0, centerTitle: true,
          title: Text(t('تواصل معنا', 'Contact us'), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
          actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Image.asset('lib/assets/fal_brand.png', width: 60))]),
        body: SafeArea(child: AbsorbPointer(absorbing: vm.isLoading,
          child: Form(key: vm.formKey, child: ListView(
            padding: const EdgeInsets.all(20), keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(t('كيف نقدر نساعدك؟', 'How can we help?'), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF123D63))),
              const SizedBox(height: 8),
              Text(t('يسعدنا سماع اقتراحاتك والإجابة عن استفساراتك', 'We welcome your suggestions and questions'), style: const TextStyle(color: Color(0xFF64748B), height: 1.7)),
              const SizedBox(height: 22),
              Row(children: [Expanded(child: _channel(t('واتساب', 'WhatsApp'), const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF1C6096)), vm.whatsappNumber.isEmpty ? null : vm.openWhatsApp)),
                const SizedBox(width: 12), Expanded(child: _channel(t('الموقع الإلكتروني', 'Website'), const Icon(Icons.language, color: Color(0xFF1C6096)), vm.websiteUrl.isEmpty ? null : vm.openWebsite))]),
              const SizedBox(height: 28),
              Text(t('أرسل لنا رسالة', 'Send us a message'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF123D63))),
              const SizedBox(height: 18),
              TextFormField(controller: vm.mobileController, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr,
                decoration: _decoration(t('رقم الجوال', 'Mobile number'), Icons.phone_outlined),
                validator: (v) => RegExp(r'^05[0-9]{8}$').hasMatch((v ?? '').trim()) ? null : t('أدخل رقمًا صحيحًا يبدأ بـ05', 'Enter a valid number starting with 05')),
              const SizedBox(height: 20),
              TextFormField(controller: vm.commentController, minLines: 5, maxLines: 8,
                decoration: _decoration(t('رسالتك', 'Your message'), Icons.chat_bubble_outline),
                validator: (v) => (v ?? '').trim().length >= 2 ? null : t('اكتب رسالتك أولاً', 'Please write your message')),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF0F6FA), borderRadius: BorderRadius.circular(14)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.info_outline, color: Color(0xFF1C6096)), const SizedBox(width: 10),
                  Expanded(child: Text(t('اكتب تفاصيل استفسارك ليتمكن فريقنا من مساعدتك.', 'Include the details of your question so our team can help.')))])),
              const SizedBox(height: 24),
              if (vm.isLoading) const Center(child: CircularProgressIndicator()),
              FilledButton(onPressed: vm.isLoading ? null : vm.sendMessage,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1C6096), minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(t('إرسال الرسالة', 'Send message'), style: const TextStyle(fontWeight: FontWeight.w700))),
            ]))))))));
  InputDecoration _decoration(String label, IconData icon) => InputDecoration(labelText: label, prefixIcon: Icon(icon), alignLabelWithHint: true,
    filled: true, fillColor: const Color(0xFFFAFCFE),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD2DFEA))),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD2DFEA))));
  Widget _channel(String label, Widget icon, VoidCallback? action) => OutlinedButton(onPressed: action,
    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFFD2DFEA))),
    child: Column(children: [icon, const SizedBox(height: 12), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))]));
}

