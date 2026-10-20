import 'package:flutter/material.dart';
import '../../Models/EvaluationModel.dart';
import '../../Shared_View/FalDesign.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, required this.index, required this.onYesNoAnswer, required this.onTextAnswer, required this.onChoiceAnswer, required this.onRateAnswer, required this.onEmojiAnswer});
  final QuestionModel question;
  final int index;
  final void Function(int, bool) onYesNoAnswer;
  final void Function(int, String) onTextAnswer;
  final void Function(int, ChoiceModel) onChoiceAnswer;
  final void Function(int, double) onRateAnswer;
  final void Function(int, int) onEmojiAnswer;
  @override
  Widget build(BuildContext context) => falCard([
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 30, height: 30, alignment: Alignment.center,
      decoration: const BoxDecoration(color: falBlue, shape: BoxShape.circle), child: Text('${index + 1}', style: falStyle(14, color: Colors.white))),
      const SizedBox(width: 10), Expanded(child: Text(question.question, style: falStyle(16, weight: FontWeight.w800)))]),
    const SizedBox(height: 18), _input(),
  ]);
  Widget _input() {
    final answer = question.answer?.toString() ?? '';
    switch (question.type) {
      case 1:
        return Wrap(spacing: 12, runSpacing: 10, children: [
          ChoiceChip(label: Text(falText('نعم', 'Yes')), selected: answer == 'true', onSelected: (_) => onYesNoAnswer(question.questionId, true)),
          ChoiceChip(label: Text(falText('لا', 'No')), selected: answer == 'false', onSelected: (_) => onYesNoAnswer(question.questionId, false)),
        ]);
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final choice in question.choices)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: OutlinedButton(onPressed: () => onChoiceAnswer(question.questionId, choice),
            style: OutlinedButton.styleFrom(alignment: AlignmentDirectional.centerStart, padding: const EdgeInsets.all(12),
              backgroundColor: answer == choice.name ? const Color(0xFFEEF6FC) : Colors.white,
              side: BorderSide(color: answer == choice.name ? falBlue : const Color(0xFFD2DFEA))),
            child: Row(children: [Icon(answer == choice.name ? Icons.radio_button_checked : Icons.radio_button_off, color: falBlue), const SizedBox(width: 12),
              Expanded(child: Text(choice.name, style: falStyle(14)))]))),
        ]);
      case 4:
        final rating = double.tryParse(answer) ?? 0;
        return Directionality(textDirection: TextDirection.ltr, child: Wrap(alignment: WrapAlignment.center, children: [for (var i = 1; i <= 5; i++)
          IconButton(tooltip: '$i ${falText('نجوم', 'stars')}', onPressed: () => onRateAnswer(question.questionId, i.toDouble()),
            icon: Icon(i <= rating ? Icons.star_rounded : Icons.star_outline_rounded, color: falGold, size: 34)),
        ]));
      case 5:
        const emojis = ['😡', '🙁', '😐', '😊', '😍'];
        return Directionality(textDirection: TextDirection.ltr, child: Wrap(alignment: WrapAlignment.center, spacing: 4, children: [for (var i = 0; i < emojis.length; i++)
          Semantics(label: '${i + 1}/5', selected: answer == '${i + 1}', child: InkWell(onTap: () => onEmojiAnswer(question.questionId, i + 1), borderRadius: BorderRadius.circular(12),
            child: Container(width: 45, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: answer == '${i + 1}' ? const Color(0xFFEEF6FC) : Colors.transparent,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: answer == '${i + 1}' ? falBlue : Colors.transparent)), child: Text(emojis[i], style: const TextStyle(fontSize: 28))))),
        ]));
      default:
        return TextFormField(key: ValueKey(question.questionId), initialValue: answer, minLines: 3, maxLines: 6,
          decoration: InputDecoration(hintText: question.type == 6 ? falText('اكتب رسالة شكر', 'Write a thank-you message') : falText('اكتب ملاحظاتك هنا', 'Write your feedback'),
            filled: true, fillColor: const Color(0xFFFAFCFE), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD2DFEA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD2DFEA)))),
          onChanged: (value) => onTextAnswer(question.questionId, value));
    }
  }
}
