import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../api/room_api.dart';
import '../../models/room_model.dart';
import 'add_edit_room_screen.dart';
import 'room_detail_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      _roomsFuture = _fetchRooms();
    });
  }

  Future<List<Room>> _fetchRooms() async {
    final response = await RoomApi.getRoomsByOwner();
    if (response['success']) {
      List<dynamic> roomsJson = response['rooms'];
      return roomsJson.map((json) => Room.fromJson(json)).toList();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'Failed to load rooms.')),
        );
      }
      throw Exception('Failed to load rooms');
    }
  }

  void _deleteRoom(String roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await RoomApi.deleteRoom(roomId);
    if (mounted) {
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room deleted successfully!')),
        );
        _loadRooms();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['msg'] ?? 'Failed to delete room.')),
        );
      }
    }
  }

  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
    if (result == true) {
      _loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Rooms',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRooms(),
        child: FutureBuilder<List<Room>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // ✅ Show shimmer skeletons instead of spinner
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 5,
                itemBuilder: (context, index) => const _RoomSkeleton(),
              );
            }
            if (snapshot.hasError) {
              return _buildEmptyState(
                icon: Icons.error_outline,
                text: "Error: ${snapshot.error}",
                color: Colors.red,
              );
            }
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final rooms = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child:
                            const Icon(Icons.meeting_room, color: Colors.blue),
                      ),
                      title: Text(room.roomName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      subtitle: Text('Code: ${room.roomCode}',
                          style: TextStyle(color: Colors.grey.shade600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: "Edit Room",
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateAndRefresh(
                                AddEditRoomScreen(room: room)),
                          ),
                          IconButton(
                            tooltip: "Delete Room",
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRoom(room.id),
                          ),
                        ],
                      ),
                      onTap: () {
                        _navigateAndRefresh(RoomDetailScreen(roomId: room.id));
                      },
                    ),
                  );
                },
              );
            }
            return _buildEmptyState(
              icon: Icons.meeting_room_outlined,
              text: "You haven’t created any rooms yet.",
              color: Colors.grey,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(const AddEditRoomScreen()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "ROOM",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo.withOpacity(0.8),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      {required IconData icon, required String text, required Color color}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomSkeleton extends StatelessWidget {
  const _RoomSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          title: Container(
            height: 16,
            width: double.infinity,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          subtitle: Container(
            height: 14,
            width: 100,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
