import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/PinDataModel.dart';
import '../../Shared_View/FalDesign.dart';
import '../../ViewModels/EvaluationViewModel/StationEvaluationViewModel.dart';
import 'QrScannerView.dart';
import 'QuestionCard.dart';

class StationEvaluationPage extends StatelessWidget {
  const StationEvaluationPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(create: (_) => StationEvaluationViewModel(), child: const _StationBody());
}
class _StationBody extends StatefulWidget {
  const _StationBody();
  @override
  State<_StationBody> createState() => _StationState();
}
class _StationState extends State<_StationBody> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.read<StationEvaluationViewModel>().loadStations(context); }); }
  @override
  Widget build(BuildContext context) => Consumer<StationEvaluationViewModel>(builder: (context, vm, _) => FalPage(
    title: falText('تقييم زيارتك', 'Rate your visit'), loading: vm.loading,
    body: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(falText('رأيك يساعدنا نتطور', 'Your feedback helps us improve'), style: falStyle(22, weight: FontWeight.w800)), const SizedBox(height: 18),
      SegmentedButton<int>(segments: [ButtonSegment(value: 0, icon: const Icon(Icons.star_outline), label: Text(falText('تقييم المحطة', 'Station'))),
        ButtonSegment(value: 1, icon: const Icon(Icons.qr_code_scanner), label: Text(falText('مسح QR', 'Scan QR')))], selected: {vm.currentTab}, onSelectionChanged: (value) => vm.changeTab(value.first)),
    ])), Expanded(child: vm.currentTab == 1 ? QrScannerView(controller: vm.qrScannerController, onDetect: (capture) => vm.onQrDetect(context, capture), scannedResult: vm.qrResult, onRestart: vm.restartQrScanner)
      : ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
        DropdownButtonFormField<PinDataModel>(initialValue: vm.selectedStation, isExpanded: true,
          decoration: InputDecoration(labelText: falText('اختر المحطة', 'Choose a station'), prefixIcon: const Icon(Icons.local_gas_station_outlined, color: falBlue), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
          items: vm.stations.map((station) => DropdownMenuItem(value: station, child: Text(station.name ?? '', overflow: TextOverflow.ellipsis, style: falStyle(14)))).toList(),
          onChanged: (value) => vm.selectStation(context, value)), const SizedBox(height: 22),
        if (vm.stations.isEmpty && !vm.loading) ...[Text(falText('لا توجد محطات متاحة للتقييم', 'No stations available to rate'), style: falStyle(14)), TextButton(onPressed: () => vm.loadStations(context), child: Text(falText('إعادة المحاولة', 'Try again')))],
        if (vm.selectedStation == null && vm.stations.isNotEmpty) falCard([
          const Icon(Icons.local_gas_station_outlined, size: 52, color: falBlue), const SizedBox(height: 16),
          Text(falText('اختر المحطة التي زرتها', 'Choose the station you visited'), textAlign: TextAlign.center, style: falStyle(18, weight: FontWeight.w800)),
          const SizedBox(height: 8), Text(falText('ستظهر أسئلة التقييم الخاصة بالمحطة بعد اختيارها', 'The station’s questions will appear after you select it'), textAlign: TextAlign.center, style: falStyle(13, weight: FontWeight.w400)),
        ], color: const Color(0xFFEEF6FC)),
        if (vm.evaluation != null) ...[
          Text(vm.evaluation!.evaluationName, style: falStyle(18, weight: FontWeight.w800)), const SizedBox(height: 14),
          for (var i = 0; i < vm.questionCount; i++) QuestionCard(key: ValueKey(vm.getQuestion(i).questionId), question: vm.getQuestion(i), index: i,
            onYesNoAnswer: vm.setYesNoAnswer, onTextAnswer: vm.setTextAnswer, onChoiceAnswer: vm.setChoiceAnswer, onRateAnswer: vm.setRateAnswer, onEmojiAnswer: vm.setEmojiAnswer),
          if (vm.questionCount > 0) falButton(falText('إرسال التقييم', 'Send evaluation'), vm.loading ? null : () => vm.submit(context)),
          if (vm.questionCount == 0) Text(falText('لا توجد أسئلة لهذه المحطة حاليًا', 'No questions are currently available'), style: falStyle(14)),
        ] else if (vm.selectedStation != null && !vm.loading) Text(falText('لا يوجد نموذج تقييم متاح', 'No evaluation form is available'), style: falStyle(14)),
        const SizedBox(height: 24),
      ])),
    ])));
}
