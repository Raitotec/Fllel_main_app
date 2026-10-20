
import 'package:babco/Models/EvaluationModel.dart';
import 'package:babco/Models/ServicesModel.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Api/EvaluationApi/getServiceEvaluation.dart';
import '../../Api/EvaluationApi/submitEvaluation.dart';
import '../../Api/SetvicesApi.dart';
import '../../Routes/route_constants.dart';

class ServiceEvaluationViewModel extends ChangeNotifier {
  bool _disposed = false;
  @override
  void notifyListeners() { if (!_disposed) super.notifyListeners(); }

  bool loading = false;

  int currentTab = 0;

  List<ServicesModel> services = [];

  ServicesModel? selectedService;

  EvaluationModel? evaluation;

  final TextEditingController qrController = TextEditingController();

  final MobileScannerController qrScannerController = MobileScannerController();

  String? qrResult;

  bool qrScanning = true;

  //----------------------------------------------------
  // Change Tab
  //----------------------------------------------------

  void changeTab(int index) {
    currentTab = index;

    if (index == 1) {
      qrScanning = true;
      qrResult = null;
      // The scanner widget starts the camera after it is mounted.
    } else {
      qrScannerController.stop();
    }

    notifyListeners();
  }

  //----------------------------------------------------
  // Load Services
  //----------------------------------------------------

  Future loadServices(BuildContext context) async {

    loading = true;
    notifyListeners();

    services = await GetAllServices(context, "") ?? [];

    loading = false;
    notifyListeners();
  }

  //----------------------------------------------------
  // Select Service
  //----------------------------------------------------

  Future selectService(
      BuildContext context,
      ServicesModel? service,
      ) async {

    selectedService = service;

    notifyListeners();

    if (service == null) {
      evaluation = null;
      notifyListeners();
      return;
    }

    await loadEvaluation(context, service.id!);

  }

  //----------------------------------------------------
  // Load Evaluation
  //----------------------------------------------------

  Future loadEvaluation(
      BuildContext context,
      int serviceId,
      ) async {

    loading = true;

    notifyListeners();

    evaluation = await getServiceEvaluation(
      context,
      serviceId,
    );

    loading = false;

    notifyListeners();

  }

  //----------------------------------------------------
  // QR Scan
  //----------------------------------------------------

  Future<void> onQrDetect(BuildContext context, BarcodeCapture capture) async {
    if (!qrScanning || _disposed) return;

    for (final barcode in capture.barcodes) {

      if (barcode.rawValue == null) continue;
      qrScanning = false;

      await qrScannerController.stop();

      qrScanning = false;
      qrResult = barcode.rawValue;

      notifyListeners();

      try {

        await launchUrl(
          _evaluationUri(barcode.rawValue!),
          mode: LaunchMode.inAppBrowserView,
        );

      } catch (e) {

        if (!context.mounted || _disposed) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("رابط غير صالح")),
        );

      }

      return;

    }

  }

  Future<void> restartQrScanner() async {
    qrResult = null;
    qrScanning = true;
    await qrScannerController.start();
    notifyListeners();
  }

  //----------------------------------------------------
  // Get Question
  //----------------------------------------------------

  QuestionModel getQuestion(int index) {

    return evaluation!.questions[index];

  }

  //----------------------------------------------------
  // Questions Count
  //----------------------------------------------------

  int get questionCount {

    if (evaluation == null) {
      return 0;
    }

    return evaluation!.questions.length;

  }
  //----------------------------------------------------
  // Yes / No
  //----------------------------------------------------

  void setYesNoAnswer(
      int questionId,
      bool value,
      ) {
    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    question.answer = value.toString();

    notifyListeners();
  }

  //----------------------------------------------------
  // Text Answer
  //----------------------------------------------------

  void setTextAnswer(
      int questionId,
      String value,
      ) {
    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    question.answer = value;

    notifyListeners();
  }

  //----------------------------------------------------
  // Radio Choice
  //----------------------------------------------------

  void setChoiceAnswer(
      int questionId,
      ChoiceModel choice,
      ) {
    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    question.answer = choice.name;

    notifyListeners();
  }

  //----------------------------------------------------
  // Stars
  //----------------------------------------------------

  void setRateAnswer(
      int questionId,
      double value,
      ) {
    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    question.answer = value.toInt().toString();

    notifyListeners();
  }

  //----------------------------------------------------
  // Emoji
  //----------------------------------------------------

  void setEmojiAnswer(
      int questionId,
      int value,
      ) {
    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    question.answer = value.toString();

    notifyListeners();
  }

  //----------------------------------------------------
  // Get Current Answer
  //----------------------------------------------------

  dynamic getAnswer(int questionId) {

    final question = evaluation!.questions.firstWhere(
          (e) => e.questionId == questionId,
    );

    return question.answer;
  }

  //----------------------------------------------------
  // Is Question Answered
  //----------------------------------------------------

  bool isAnswered(QuestionModel question) {

    if (question.answer == null) {
      return false;
    }

    if (question.answer is String) {
      return question.answer.toString().trim().isNotEmpty;
    }

    return true;
  }

  //----------------------------------------------------
  // Clear Answers
  //----------------------------------------------------

  void clearAnswers() {

    if (evaluation == null) return;

    for (var q in evaluation!.questions) {
      q.answer = null;
    }

    notifyListeners();
  }

  //----------------------------------------------------
  // Get Emoji
  //----------------------------------------------------

  String emojiFace(int value) {

    switch (value) {
      case 1:
        return "\u{1F621}";

      case 2:
        return "\u{1F641}";

      case 3:
        return "\u{1F610}";

      case 4:
        return "\u{1F60A}";

      case 5:
        return "\u{1F60D}";

      default:
        return "\u{1F610}";
    }
  }
  //----------------------------------------------------
  // Validate
  //----------------------------------------------------

  bool validateAnswers() {
    if (evaluation == null) {
      return false;
    }

    for (final question in evaluation!.questions) {
      if (question.answer == null) {
        return false;
      }

      if (question.answer is String &&
          question.answer.toString().trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  //----------------------------------------------------
  // Build Submit Model
  //----------------------------------------------------

  SubmitEvaluationModel buildSubmitModel() {
    return SubmitEvaluationModel(
      evaluationId: evaluation!.evaluationId,
      answers: evaluation!.questions.map((q) {
        return AnswerModel(
          questionId: q.questionId,
          answer: q.answer.toString(),
        );
      }).toList(),
    );
  }

  //----------------------------------------------------
  // Submit
  //----------------------------------------------------

  Future<bool> submit(BuildContext context) async {
    if (loading || _disposed) return false;
    if (evaluation == null) {
      return false;
    }

    if (!validateAnswers()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("\u0628\u0631\u062C\u0627\u0621 \u0627\u0644\u0625\u062C\u0627\u0628\u0629 \u0639\u0644\u0649 \u062C\u0645\u064A\u0639 \u0627\u0644\u0623\u0633\u0626\u0644\u0629"),
        ),
      );
      return false;
    }

    loading = true;
    notifyListeners();

    final model = buildSubmitModel();

    final result = await submitEvaluation(
      context,
      model,
    );

    loading = false;
    notifyListeners();

    if (!context.mounted || _disposed) return false;
    if (result == true) {
      clearAfterSubmit();
      Navigator.pushNamedAndRemoveUntil(context, homeRoute,(Route<dynamic> r)=>false);

      return true;
    }

    return false;
  }

  //----------------------------------------------------
  // Clear
  //----------------------------------------------------

  void clearAfterSubmit() {
    evaluation = null;
    selectedService = null;

    qrController.clear();

    notifyListeners();
  }

  //----------------------------------------------------
  // Dispose
  //----------------------------------------------------

  @override
  void dispose() {
    _disposed = true;
    qrController.dispose();
    qrScannerController.dispose();
    super.dispose();
  }
}


Uri _evaluationUri(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !['http', 'https'].contains(uri.scheme) || uri.host.isEmpty) throw const FormatException();
  return uri;
}
