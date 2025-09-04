
// lib/screens/tests/add_edit_question_screen.dart

import 'package:flutter/material.dart';
import '../../models/test_model.dart';

class AddEditQuestionDialog extends StatefulWidget {
  final Question? question;
  const AddEditQuestionDialog({super.key, this.question});

  @override
  State<AddEditQuestionDialog> createState() => _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionTextController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;

  bool get _isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    _questionTextController =
        TextEditingController(text: widget.question?.questionText ?? '');
    _optionControllers = List.generate(
      widget.question?.options.length ?? 4,
      (index) =>
          TextEditingController(text: widget.question?.options[index] ?? ''),
    );
    _correctAnswerIndex = widget.question?.correctAnswerIndex ?? 0;
  }

  void _saveAndPop() {
    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        questionText: _questionTextController.text,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswerIndex: _correctAnswerIndex,
      );
      Navigator.of(context).pop(newQuestion);
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        _isEditing ? 'Edit Question' : 'Add Question',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Question Text Field ---
              TextFormField(
                controller: _questionTextController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  prefixIcon: const Icon(Icons.help_outline),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter question text' : null,
              ),
              const SizedBox(height: 20),

              // --- Options Fields ---
              ...List.generate(_optionControllers.length, (index) {
                bool isCorrect = index == _correctAnswerIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      prefixIcon: Radio<int>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: (value) =>
                            setState(() => _correctAnswerIndex = value ?? 0),
                      ),
                      suffixIcon: isCorrect
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: isCorrect,
                      fillColor: isCorrect
                          ? Colors.green.withOpacity(0.08)
                          : Colors.transparent,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter option' : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
     actions: [
  Row(
    children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _saveAndPop,
          child: const Text("Save"),
        ),
      ),
    ],
  ),
],
    );
  }
}
