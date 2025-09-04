
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../api/test_api.dart';

class TestResultScreen extends StatefulWidget {
  final String testId;
  const TestResultScreen({super.key, required this.testId});

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  bool isLoading = true;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    final res = await TestApi.getTestResult(widget.testId);
    if (!mounted) return;

    if (res["error"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["error"])),
      );
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      result = res;
      isLoading = false;
    });
  }

  Widget _buildOption(
      String text, bool isSelected, bool isCorrect, bool isWrongSelected) {
    Color bgColor = Colors.grey.shade200;
    Icon? icon;

    if (isCorrect) {
      bgColor = Colors.green.shade100;
      icon = const Icon(Icons.check_circle, color: Colors.green);
    } else if (isWrongSelected) {
      bgColor = Colors.red.shade100;
      icon = const Icon(Icons.cancel, color: Colors.red);
    } else if (isSelected) {
      bgColor = Colors.blue.shade50;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? Colors.green
              : isWrongSelected
                  ? Colors.red
                  : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          if (icon != null) icon,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text("No result available")),
      );
    }

    final testTitle = result!["testTitle"] as String? ?? "Test Result";
    final score = result!["score"] as int? ?? 0;
    final total = result!["total"] as int? ?? 0;
    final percentageStr = result!["percentage"]?.toString() ?? "0";
    final percentage = total > 0 ? score / total : 0.0;
    final questions = result!["questions"] as List<dynamic>? ?? [];

 return Scaffold(
  body: CustomScrollView(
    slivers: [
      // AppBar only
      SliverAppBar(
        pinned: true,
        expandedHeight: 20,
        backgroundColor: Colors.blue.shade700,
        flexibleSpace: const FlexibleSpaceBar(
          centerTitle: true,
          title: Text("Test Result", style: TextStyle(fontSize: 18, color: Colors.white,)),
        ),
      ),

      // Result card (white background with CircularPercentIndicator)
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: percentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${percentageStr}%",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                progressColor:
                    percentage == 1.0 ? Colors.green : Colors.orange,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 8),
              Text(
                testTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),

      // Questions list
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final q = questions[index];
              final options = q["options"] as List<dynamic>;
              final correctIndex = q["correctAnswerIndex"] as int? ?? -1;
              final selectedIndex = q["selectedAnswerIndex"] as int?;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q${index + 1}. ${q["questionText"]}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...options.asMap().entries.map((entry) {
                        final optIndex = entry.key;
                        final optText = entry.value;

                        final isCorrect = optIndex == correctIndex;
                        final isSelected = optIndex == selectedIndex;
                        final isWrongSelected = isSelected && !isCorrect;

                        return _buildOption(
                            optText, isSelected, isCorrect, isWrongSelected);
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
            childCount: questions.length,
          ),
        ),
      ),
    ],
  ),
);
  }
}
