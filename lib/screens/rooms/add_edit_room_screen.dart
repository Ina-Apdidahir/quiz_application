import 'package:flutter/material.dart';
import '../../api/room_api.dart';
import '../../models/room_model.dart';

class AddEditRoomScreen extends StatefulWidget {
  final Room? room;

  const AddEditRoomScreen({super.key, this.room});

  @override
  _AddEditRoomScreenState createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  bool get _isEditing => widget.room != null;

  @override
  void initState() {
    super.initState();
    _roomNameController =
        TextEditingController(text: widget.room?.roomName ?? '');
    _descriptionController =
        TextEditingController(text: widget.room?.description ?? '');
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final roomName = _roomNameController.text;
      final description = _descriptionController.text;
      late Map<String, dynamic> response;

      if (_isEditing) {
        response =
            await RoomApi.updateRoom(widget.room!.id, roomName, description);
      } else {
        response = await RoomApi.addRoom(roomName, description);
      }

      setState(() => _isLoading = false);

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Room saved successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['msg'] ?? 'Failed to save room.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Room' : 'Create Room';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _roomNameController,
                    decoration: InputDecoration(
                      labelText: 'Room Name',
                      prefixIcon: const Icon(Icons.meeting_room_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter a room name'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveRoom,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.save_rounded),
                            label: const Text(
                              "Save Room",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
