import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/ServicesModel.dart';
import '../../Shared_View/FalDesign.dart';
import '../../ViewModels/EvaluationViewModel/ServiceEvaluationViewModel.dart';
import 'QrScannerView.dart';
import 'QuestionCard.dart';

class ServiceEvaluationPage extends StatelessWidget {
  const ServiceEvaluationPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => ServiceEvaluationViewModel(), child: const _ServiceBody());
}
class _ServiceBody extends StatefulWidget {
  const _ServiceBody();
  @override
  State<_ServiceBody> createState() => _ServiceState();
}
class _ServiceState extends State<_ServiceBody> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.read<ServiceEvaluationViewModel>().loadServices(context); }); }
  @override
  Widget build(BuildContext context) => Consumer<ServiceEvaluationViewModel>(builder: (context, vm, _) => FalPage(
    title: falText('تقييم الخدمات', 'Rate our services'), loading: vm.loading,
    body: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(falText('كيف كانت تجربتك؟', 'How was your experience?'), style: falStyle(22, weight: FontWeight.w800)), const SizedBox(height: 18),
      SegmentedButton<int>(segments: [ButtonSegment(value: 0, icon: const Icon(Icons.star_outline), label: Text(falText('تقييم الخدمة', 'Service'))),
        ButtonSegment(value: 1, icon: const Icon(Icons.qr_code_scanner), label: Text(falText('مسح QR', 'Scan QR')))], selected: {vm.currentTab}, onSelectionChanged: (value) => vm.changeTab(value.first)),
    ])), Expanded(child: vm.currentTab == 1 ? QrScannerView(controller: vm.qrScannerController, onDetect: (capture) => vm.onQrDetect(context, capture), scannedResult: vm.qrResult, onRestart: vm.restartQrScanner)
      : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        DropdownButtonFormField<ServicesModel>(initialValue: vm.selectedService, isExpanded: true,
          decoration: InputDecoration(labelText: falText('اختر الخدمة', 'Choose a service'), prefixIcon: const Icon(Icons.handyman_outlined, color: falBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          items: vm.services.map((station) => DropdownMenuItem(value: station, child: Text(station.name ?? '', overflow: TextOverflow.ellipsis, style: falStyle(14)))).toList(),
          onChanged: (value) => vm.selectService(context, value)), const SizedBox(height: 22),
        if (vm.services.isEmpty && !vm.loading) ...[Text(falText('لا توجد خدمات متاحة للتقييم', 'No services available to rate'), style: falStyle(14)), TextButton(onPressed: () => vm.loadServices(context), child: Text(falText('إعادة المحاولة', 'Try again')))],
        if (vm.selectedService == null && vm.services.isNotEmpty) falCard([
          const Icon(Icons.handyman_outlined, size: 52, color: falBlue), const SizedBox(height: 16),
          Text(falText('اختر الخدمة التي استخدمتها', 'Choose the service you used'), textAlign: TextAlign.center, style: falStyle(18, weight: FontWeight.w800)),
          const SizedBox(height: 8), Text(falText('ستظهر أسئلة التقييم الخاصة بالخدمة بعد اختيارها', 'The station’s questions will appear after you select it'), textAlign: TextAlign.center, style: falStyle(13, weight: FontWeight.w400)),
        ], color: const Color(0xFFEEF6FC)),
        if (vm.evaluation != null) ...[
          Text(vm.evaluation!.evaluationName, style: falStyle(18, weight: FontWeight.w800)), const SizedBox(height: 14),
          for (var i = 0; i < vm.questionCount; i++) QuestionCard(key: ValueKey(vm.getQuestion(i).questionId), question: vm.getQuestion(i), index: i,
            onYesNoAnswer: vm.setYesNoAnswer, onTextAnswer: vm.setTextAnswer, onChoiceAnswer: vm.setChoiceAnswer, onRateAnswer: vm.setRateAnswer, onEmojiAnswer: vm.setEmojiAnswer),
          if (vm.questionCount > 0) falButton(falText('إرسال التقييم', 'Send evaluation'), vm.loading ? null : () => vm.submit(context)),
          if (vm.questionCount == 0) Text(falText('لا توجد أسئلة لهذه الخدمة حاليًا', 'No questions are currently available'), style: falStyle(14)),
        ] else if (vm.selectedService != null && !vm.loading) Text(falText('لا يوجد نموذج تقييم متاح', 'No evaluation form is available'), style: falStyle(14)),
        const SizedBox(height: 24),
      ])),
    ])));
}

