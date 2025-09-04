
class Test {
  final String id;
  final String testTitle;
  final List<Question> questions;
  final DateTime createdAt; // <-- add this

  Test({
    required this.id,
    required this.testTitle,
    required this.questions,
    required this.createdAt, // <-- include in constructor
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List? ?? [];
    List<Question> questions = questionsList.map((i) => Question.fromJson(i)).toList();

    return Test(
      id: json['_id'],
      testTitle: json['testTitle'],
      questions: questions,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class Question {
  final String? id;
  String questionText;
  List<String> options;
  int correctAnswerIndex;

  Question({
    this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'],
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}
