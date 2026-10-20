import 'package:babco/Models/EvaluationModel.dart';
import 'package:babco/Views/Evaluation/QuestionCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('long choices fit a narrow screen and report the original choice', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final choice = ChoiceModel(id: 8, name: 'A long choice that wraps across several lines on a narrow device without clipping its answer');
    ChoiceModel? selected;
    final question = QuestionModel(questionId: 7, question: 'Choose an answer', type: 3, choices: [choice]);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestionCard(question: question, index: 0,
      onYesNoAnswer: (_, __) {}, onTextAnswer: (_, __) {}, onChoiceAnswer: (_, value) => selected = value,
      onRateAnswer: (_, __) {}, onEmojiAnswer: (_, __) {}))));
    await tester.tap(find.text(choice.name));
    expect(selected, same(choice));
    expect(tester.takeException(), isNull);
  });
  testWidgets('decimal stored ratings render selected stars and preserve new rating', (tester) async {
    double? rating;
    final question = QuestionModel(questionId: 5, question: 'Rate your visit', type: 4, choices: [], answer: '3.0');
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: QuestionCard(question: question, index: 0,
      onYesNoAnswer: (_, __) {}, onTextAnswer: (_, __) {}, onChoiceAnswer: (_, __) {},
      onRateAnswer: (_, value) => rating = value, onEmojiAnswer: (_, __) {}))));
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    await tester.tap(find.byType(IconButton).last);
    expect(rating, 5.0);
    expect(tester.takeException(), isNull);
  });
}
