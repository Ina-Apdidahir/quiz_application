import 'package:flutter/material.dart';
import '../../api/test_api.dart';
import '../../models/test_model.dart';
import 'add_edit_question_screen.dart';

class TestDetailScreen extends StatefulWidget {
  final String testId;
  const TestDetailScreen({super.key, required this.testId});

  @override
  _TestDetailScreenState createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  late Future<Test> _testFuture;

  @override
  void initState() {
    super.initState();
    _loadTestDetails();
  }

  void _loadTestDetails() {
    setState(() {
      _testFuture = _fetchTest();
    });
  }

  Future<Test> _fetchTest() async {
    final response = await TestApi.getTestById(widget.testId);
    if (response['success']) {
      return Test.fromJson(response['test']);
    } else {
      throw Exception(response['msg'] ?? 'Failed to load test details');
    }
  }

  void _manageQuestion({Question? question}) async {
    final result = await showDialog<Question>(
      context: context,
      builder: (context) => AddEditQuestionDialog(question: question),
    );

    if (result != null) {
      late final Map<String, dynamic> response;
      final isEditing = question != null;

      if (isEditing) {
        response = await TestApi.updateQuestionInTest(
            widget.testId, result.id!, result);
      } else {
        response = await TestApi.addQuestionToTest(widget.testId, result);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'An error occurred.')),
        );
        if (response['success']) {
          _loadTestDetails();
        }
      }
    }
  }

  void _deleteQuestion(String questionId) async {
    final response =
        await TestApi.deleteQuestionInTest(widget.testId, questionId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['msg'] ?? 'An error occurred.')),
      );
      if (response['success']) _loadTestDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Test Details'),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: FutureBuilder<Test>(
          future: _testFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            if (snapshot.hasData) {
              final test = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async => _loadTestDetails(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Test Info Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(test.testTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("${test.questions.length} Questions",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Questions Section
                    if (test.questions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.help_outline,
                                size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text("No questions yet",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text("Tap + to add your first question",
                                style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: test.questions.map((question) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question.questionText,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _manageQuestion(question: question);
                                        } else if (value == 'delete') {
                                          _deleteQuestion(question.id!);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(Icons.edit,
                                                color: Colors.blue),
                                            title: Text("Edit"),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(Icons.delete,
                                                color: Colors.red),
                                            title: Text("Delete"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Full-width Options
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: question.options
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final option = entry.value;
                                    final isCorrect =
                                        index == question.correctAnswerIndex;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: isCorrect
                                            ? Colors.green[50]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: isCorrect
                                                ? Colors.green
                                                : Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: isCorrect
                                              ? Colors.green[800]
                                              : Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No data found.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _manageQuestion(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "QUESTION",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          backgroundColor:
              Colors.indigo.withOpacity(0.8), // semi-transparent bg
          elevation: 8, // adds subtle blur-like shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ));
  }
}
