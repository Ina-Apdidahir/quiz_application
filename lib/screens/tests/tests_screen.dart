// =========================================================================
// screens/tests/tests_screen.dart
// Path: lib/screens/tests/tests_screen.dart (Creative Professional UI)
// =========================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/test_api.dart';
import '../../models/test_model.dart';
import 'add_edit_test_screen.dart';
import 'test_detail_screen.dart';

class TestsScreen extends StatefulWidget {
  final String roomId;
  const TestsScreen({super.key, required this.roomId});

  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  late Future<List<Test>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  void _loadTests() {
    setState(() {
      _testsFuture = _fetchTests();
    });
  }

  Future<List<Test>> _fetchTests() async {
    final response = await TestApi.getTestsByRoom(widget.roomId);
    if (response['success']) {
      List<dynamic> testsJson = response['tests'];
      return testsJson.map((json) => Test.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tests');
    }
  }

  void _deleteTest(String testId) async {
    final response = await TestApi.deleteTest(testId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['msg'] ?? 'An error occurred.')),
      );
      if (response['success']) _loadTests();
    }
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
    if (result == true) _loadTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text(
          "Tests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Test>>(
        future: _testsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("⚠️ Something went wrong: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final tests = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final test = tests[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TestDetailScreen(testId: test.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Leading icon with gradient background
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.description,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        // Test info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.testTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${test.questions.length} questions",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Created: ${DateFormat.yMMMd().format(DateTime.now())}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () => _navigateAndRefresh(
                                AddEditTestScreen(
                                  roomId: widget.roomId,
                                  test: test,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTest(test.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text(
              "No tests available in this room",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(
          AddEditTestScreen(roomId: widget.roomId),
        ),
        icon: const Icon(Icons.add),
        label: const Text("New Test"),
      ),
    );
  }
}
