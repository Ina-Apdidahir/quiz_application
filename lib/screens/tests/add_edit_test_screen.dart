// lib/screens/tests/add_edit_test_screen.dart

import 'package:flutter/material.dart';
import '../../api/test_api.dart';
import '../../models/test_model.dart';
import 'add_edit_question_screen.dart';

class AddEditTestScreen extends StatefulWidget {
  final String roomId;
  final Test? test;

  const AddEditTestScreen({super.key, required this.roomId, this.test});

  @override
  State<AddEditTestScreen> createState() => _AddEditTestScreenState();
}

class _AddEditTestScreenState extends State<AddEditTestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _testTitleController;
  late List<Question> _questions;
  bool _isLoading = false;

  bool get _isEditing => widget.test != null;

  @override
  void initState() {
    super.initState();
    _testTitleController =
        TextEditingController(text: widget.test?.testTitle ?? '');
    _questions = widget.test?.questions
            .map((q) => Question.fromJson(q.toJson()))
            .toList() ??
        [];
  }

  Future<void> _saveTest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final title = _testTitleController.text;
      late final Map<String, dynamic> response;

      if (_isEditing) {
        response = await TestApi.updateTest(widget.test!.id, title, _questions);
      } else {
        response = await TestApi.createTest(widget.roomId, title, _questions);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'An error occurred.')),
        );
        if (response['success']) Navigator.of(context).pop(true);
      }
    }
  }

  void _showQuestionDialog({Question? question, int? index}) async {
    final result = await showDialog<Question>(
      context: context,
      builder: (context) => AddEditQuestionDialog(question: question),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _questions[index] = result;
        } else {
          _questions.add(result);
        }
      });
    }
  }

  @override
  void dispose() {
    _testTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditing ? "Edit Test" : "Create Test",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Test Title Form ---
              // --- Test Title Form ---
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Test Title",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _testTitleController,
                      decoration: const InputDecoration(
                        hintText: "Enter test title",
                        prefixIcon:
                            Icon(Icons.text_fields, color: Colors.indigo),
                        filled: true,
                        fillColor: Color(0xFFF7F7F9), // light background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none, // no outline
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Please enter a test title"
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Questions Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Questions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showQuestionDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_questions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No questions added yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._questions.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Question q = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      title: Text(
                        q.questionText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "${q.options.length} options",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Edit Button ---
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.indigo,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                              onPressed: () =>
                                  _showQuestionDialog(question: q, index: idx),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // --- Delete Button ---
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete,
                                  color: Colors.white, size: 18),
                              onPressed: () =>
                                  setState(() => _questions.removeAt(idx)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 80),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            ),
        ],
      ),

      // --- Save Button ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _saveTest,
            icon: const Icon(Icons.save),
            label: Text(
              _isEditing ? "Update Test" : "Create Test",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
