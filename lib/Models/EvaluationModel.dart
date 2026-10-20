class EvaluationModel {

  int evaluationId;
  String evaluationName;
  String type;
  TargetModel? station;
  TargetModel? service;
  List<QuestionModel> questions;

  EvaluationModel({

    required this.evaluationId,
    required this.evaluationName,
    required this.type,
    this.station,
    this.service,
    required this.questions,
  });

  factory EvaluationModel.fromJson(Map<String,dynamic> json){

    return EvaluationModel(

      evaluationId: json["evaluation_id"],
      evaluationName: json["evaluation_name"],
      type: json["type"] ?? "",
      station: json["station"] != null ? TargetModel.fromJson(json["station"]) : null,
      service: json["service"] != null ? TargetModel.fromJson(json["service"]) : null,

      questions: (json["questions"] as List)
          .map((e)=>QuestionModel.fromJson(e))
          .toList(),

    );
  }

}

class TargetModel {
  int id;
  String name;

  TargetModel({
    required this.id,
    required this.name,
  });

  factory TargetModel.fromJson(Map<String,dynamic> json){

    return TargetModel(

      id: json["id"],
      name: json["name"] ?? "",

    );
  }

}

class QuestionModel{

  int questionId;

  String question;

  int type;

  List<ChoiceModel> choices;

  dynamic answer;

  QuestionModel({

    required this.questionId,
    required this.question,
    required this.type,
    required this.choices,
    this.answer

  });

  factory QuestionModel.fromJson(Map<String,dynamic> json){

    return QuestionModel(

      questionId: json["question_id"],
      question: json["question"],
      type: json["type"],

      choices:(json["choices"] as List)
          .map((e)=>ChoiceModel.fromJson(e))
          .toList(),

    );

  }

}

class ChoiceModel{
  int id;
  String name;

  ChoiceModel({

    required this.id,
    required this.name,

  });

  factory ChoiceModel.fromJson(Map<String,dynamic> json){

    return ChoiceModel(

      id: json["id"],
      name: json["name"],

    );

  }

}

class SubmitEvaluationModel {
  int? evaluationId;
  List<AnswerModel>? answers;

  SubmitEvaluationModel({
    this.evaluationId,
    this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      "evaluation_id": evaluationId,
      "answers": answers?.map((e) => e.toJson()).toList()
    };
  }
}

class AnswerModel {
  int? questionId;
  String? answer;

  AnswerModel({
    this.questionId,
    this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      "question_id": questionId,
      "answer": answer,
    };
  }
}