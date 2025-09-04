import 'package:flutter/material.dart';
import '../../api/test_api.dart';
import 'test_result_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final String testId;
  const TestDetailScreen({super.key, required this.testId});

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  bool isLoading = true;
  String? testTitle;
  List<dynamic> unansweredQuestions = [];
  Map<String, int?> selectedAnswers = {}; // questionId -> selectedIndex
  int currentQuestionIndex = 0;
  bool isSubmitting = false; // To prevent double taps

  @override
  void initState() {
    super.initState();
    _fetchUnanswered();
  }

  Future<void> _fetchUnanswered() async {
    final res = await TestApi.getUnAnsweredQuestionsByTestId(widget.testId);

    if (!mounted) return;

    if (res['success'] == true) {
      final questions = res['unansweredQuestions'] as List<dynamic>;

      if (questions.isEmpty) {
        // If no questions are left, go straight to results.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TestResultScreen(testId: widget.testId),
          ),
        );
        return;
      }

      setState(() {
        unansweredQuestions = questions;
        testTitle = res['testTitle'];
        isLoading = false;
        // No need to pre-fill selectedAnswers, it will be populated on tap.
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['msg'] ?? "Failed to load test")),
      );
    }
  }

  // FIXED: Handles submission and state update in one place.
  Future<void> _submitAnswer(String questionId, int answerIndex) async {
    if (isSubmitting) return; // Prevent multiple submissions

    setState(() {
      isSubmitting = true;
      // Instantly update the UI to show the user's selection
      selectedAnswers[questionId] = answerIndex;
    });

    try {
      // The API call now confirms the result
      await TestApi.submitAnswer(widget.testId, questionId, answerIndex);
      // Backend confirmation is logged, but UI is already updated optimistically.
    } catch (e) {
      // If submission fails, revert the selection and show an error
      setState(() {
        selectedAnswers.remove(questionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit. Please try again.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < (unansweredQuestions.length - 1)) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Navigate to results screen when the last question is answered
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(testId: widget.testId),
        ),
      );
    }
  }

  // This function is not used in your UI but is kept for completeness.
  // void _prevQuestion() {
  //   if (currentQuestionIndex > 0) {
  //     setState(() {
  //       currentQuestionIndex--;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (unansweredQuestions.isEmpty) {
      // This is a fallback view, though the logic in _fetchUnanswered should prevent it.
      return Scaffold(
          appBar: AppBar(title: Text(testTitle ?? "Test Done")),
          body: Center(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => TestResultScreen(testId: widget.testId)),
              );
            },
            child: const Text("View Results"),
          )));
    }

    final question = unansweredQuestions[currentQuestionIndex];
    final questionId = question["_id"] as String;
    // This now works because the backend is sending it.
    final correctAnswerIndex = question['correctAnswerIndex'] as int?;
    bool isAnswered = selectedAnswers.containsKey(questionId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          testTitle ?? "Test",
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${currentQuestionIndex + 1} of ${unansweredQuestions.length}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question['questionText'] ?? "Question",
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Column(
              children: (question['options'] as List<dynamic>)
                  .asMap()
                  .entries
                  .map((entry) {
                final optIndex = entry.key;
                final optText = entry.value as String;

                bool isSelected = selectedAnswers[questionId] == optIndex;
                // We can safely compare now because `correctAnswerIndex` is not null.
                bool isCorrect = optIndex == correctAnswerIndex;

                Color borderColor = Colors.grey.shade400;
                Color iconColor = Colors.transparent;
                IconData? icon;

                if (isAnswered) {
                  if (isSelected && isCorrect) {
                    borderColor = Colors.green;
                    iconColor = Colors.green;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isCorrect) {
                    borderColor = Colors.red;
                    iconColor = Colors.red;
                    icon = Icons.cancel;
                  } else if (isCorrect) {
                    // This highlights the correct answer if the user chose wrong.
                    borderColor = Colors.green;
                    iconColor = Colors.green;
                    icon = Icons
                        .check_circle_outline; // A different icon for clarity
                  }
                }

                return GestureDetector(
                  onTap: isAnswered
                      ? null
                      : () => _submitAnswer(questionId, optIndex),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            optText,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                        if (icon != null) Icon(icon, color: iconColor),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: isAnswered ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAnswered ? Colors.blueAccent : Colors.grey,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  currentQuestionIndex < unansweredQuestions.length - 1
                      ? "Next"
                      : "Finish",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20), // Added bottom padding
          ],
        ),
      ),
    );
  }
}
