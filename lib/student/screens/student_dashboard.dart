import 'package:flutter/material.dart';
import 'package:quiz_application/api/auth_api.dart';
import 'package:quiz_application/api/room_api.dart';
import 'package:quiz_application/models/user_model.dart';
import 'package:quiz_application/screens/rooms/room_tests_screen.dart';
import 'package:quiz_application/teacher/screens/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the screens that will be accessible from the drawer
import 'package:quiz_application/screens/auth/login_screen.dart';
import 'package:quiz_application/screens/profile/profile_screen.dart';
import 'package:quiz_application/teacher/screens/app_license_screen.dart';
import 'package:quiz_application/teacher/screens/app_setting_screen.dart';
import 'package:quiz_application/teacher/screens/developer_info_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> myRooms = [];
  bool isLoadingRooms = false;
  bool isSearching = false;

  // Added state variable to hold the fetched user data
  User? _currentUser;

  Map<String, dynamic>? searchResult; // { room: {...} } or { error: '...' }

  // Colors / tokens
  static const _primary = Color(0xFF2563EB); // blue-600
  static const _bg = Color(0xFFF6F7FB);

  // For navigation
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    // Placeholder for dashboard content (will be handled by the main body)
    SizedBox(),
    ProfileScreen(),
    DeveloperInfoPage(),
    InfoPage(),
    // AboutUsPage(),
  ];

  final List<String> _titles = const [
    "Dashboard",
    "Profile",
    "Developer Info",
    "About Us",
  ];

  @override
  void initState() {
    super.initState();
    _fetchMyRooms();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMyRooms() async {
    setState(() => isLoadingRooms = true);
    final res = await RoomApi.getMyRooms();
    if (mounted) {
      setState(() {
        myRooms = res['success'] == true ? (res['rooms'] as List<dynamic>) : [];
        isLoadingRooms = false;
      });
    }
  }

  // Modified to store the user data in the state
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // Handle the case where the user is not authenticated
      if (mounted) {
        setState(() {
          _currentUser = null;
        });
      }
      return;
    }
    try {
      final response = await AuthApi.getUserData(token);
      if (response['success']) {
        // Assuming your user model has a constructor for this
        final userData = response['userData'];
        // Remapping 'user' to 'id' as per the original logic
        userData['id'] = userData['user'];
        if (mounted) {
          setState(() {
            _currentUser = User.fromJson(userData);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentUser = null;
          });
        }
      }
    } catch (e) {
      // Handle any potential errors during the API call
      if (mounted) {
        setState(() {
          _currentUser = null;
        });
      }
    }
  }

  Future<void> _searchRoom() async {
    final code = _searchCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      isSearching = true;
      searchResult = null;
    });

    final res = await RoomApi.searchRoomByCode(code);
    if (!mounted) return;

    setState(() {
      if (res['room'] != null) {
        searchResult = res;
      } else {
        searchResult = {'error': res['error'] ?? 'Room not found'};
      }
      isSearching = false;
    });
  }

  Future<void> _joinRoom() async {
    if (searchResult == null || searchResult!['room'] == null) return;
    final code = searchResult!['room']['roomCode'];
    final res = await RoomApi.joinRoom(code);

    if (!mounted) return;
    if (res['message'] == 'Successfully joined the room!') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'])),
      );
      _searchCtrl.clear();
      setState(() => searchResult = null);
      _fetchMyRooms();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Failed to join room.')),
      );
    }
  }

  // Navigation methods for drawer items
  void _navigateToPage(int index) {
    if (index == 0) {
      // Dashboard - just close the drawer
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context); // Close the drawer

    // Navigate to the selected page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _fetchMyRooms,
        edgeOffset: 140,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // HERO HEADER
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 180,
              elevation: 0,
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              title: const Text('Student Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              // actions: [
              //   IconButton(
              //     onPressed: _fetchMyRooms,
              //     icon: const Icon(Icons.refresh_rounded),
              //     tooltip: 'Refresh',
              //   ),
              //   const SizedBox(width: 4),
              // ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                      child: _HeaderStats(
                        totalRooms: myRooms.length,
                        // Passed the username from the state to the widget
                        username: _currentUser?.name,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SEARCH / JOIN CARD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _SearchJoinCard(
                  controller: _searchCtrl,
                  isSearching: isSearching,
                  onSearch: _searchRoom,
                  searchResult: searchResult,
                  onJoin: _joinRoom,
                  onClear: () => setState(() => searchResult = null),
                ),
              ),
            ),

            // SECTION TITLE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'My Rooms',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Sort',
                      onSelected: (v) {
                        setState(() {
                          if (v == 'name') {
                            myRooms.sort((a, b) => (a['roomName'] ?? '')
                                .toString()
                                .toLowerCase()
                                .compareTo(
                                  (b['roomName'] ?? '')
                                      .toString()
                                      .toLowerCase(),
                                ));
                          } else {
                            myRooms.sort((a, b) =>
                                (a['roomCode'] ?? '').toString().compareTo(
                                      (b['roomCode'] ?? '').toString(),
                                    ));
                          }
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'name', child: Text('Sort by name')),
                        PopupMenuItem(
                            value: 'code', child: Text('Sort by code')),
                      ],
                      child: Row(
                        children: const [
                          Icon(Icons.sort_rounded,
                              size: 18, color: Colors.black54),
                          SizedBox(width: 6),
                          Text('Sort', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ROOM LIST
            if (isLoadingRooms)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList.list(
                  children: const [
                    _SkeletonCard(),
                    SizedBox(height: 12),
                    _SkeletonCard(),
                    SizedBox(height: 12),
                    _SkeletonCard(),
                  ],
                ),
              )
            else if (myRooms.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  title: "No rooms yet",
                  message:
                      "Search by code above to join your first room. Your rooms will appear here.",
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList.builder(
                  itemCount: myRooms.length,
                  itemBuilder: (context, index) {
                    final room = myRooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoomCard(
                        name: room['roomName'] ?? 'Untitled Room',
                        code: room['roomCode'] ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomTestsScreen(roomId: room['_id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Drawer builder method with TeacherNav content
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_currentUser?.name ?? "Student"),
            accountEmail: Text(_currentUser?.email ?? "Loading..."),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: const BoxDecoration(
              color: Colors.indigo,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_rounded),
            title: const Text("Dashboard"),
            onTap: () => _navigateToPage(0),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => _navigateToPage(1),
          ),
          ListTile(
            leading: const Icon(Icons.engineering),
            title: const Text("Developer "),
            onTap: () => _navigateToPage(2),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About App"),
            onTap: () => _navigateToPage(3),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------- Header Stats (Hero) ----------
class _HeaderStats extends StatelessWidget {
  const _HeaderStats({required this.totalRooms, this.username});

  final int totalRooms;
  // Added optional username to the constructor
  final String? username;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Used the username to create the welcome message
    final welcomeText =
        username != null ? 'Welcome 👋 $username' : 'Welcome 👋';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeText,
          style: text.titleMedium?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your Learning Rooms',
          style: text.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _MetricChip(
              label: 'Joined Rooms',
              value: '$totalRooms',
              icon: Icons.meeting_room_rounded,
            ),
            const SizedBox(width: 12),
            _MetricChip(
              label: 'Status',
              value: totalRooms > 0 ? 'Ready' : 'Getting started',
              icon: Icons.check_circle_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Search / Join Card ----------
class _SearchJoinCard extends StatelessWidget {
  const _SearchJoinCard({
    required this.controller,
    required this.isSearching,
    required this.onSearch,
    required this.searchResult,
    required this.onJoin,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSearch;
  final Map<String, dynamic>? searchResult;
  final VoidCallback onJoin;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded, color: Colors.black54),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => onSearch(),
                  decoration: const InputDecoration(
                    hintText: 'Enter room code to join',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isSearching ? null : onSearch,
                icon: isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: const Text('Find'),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: searchResult == null
                ? const SizedBox.shrink()
                : Padding(
                    key: ValueKey(searchResult),
                    padding: const EdgeInsets.only(top: 12),
                    child: _SearchResultTile(
                      result: searchResult!,
                      onJoin: onJoin,
                      onClear: onClear,
                      text: text,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onJoin,
    required this.onClear,
    required this.text,
  });

  final Map<String, dynamic> result;
  final VoidCallback onJoin;
  final VoidCallback onClear;
  final TextTheme text;

  @override
  Widget build(BuildContext context) {
    final room = result['room'];
    final bool found = room != null;

    if (!found) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                result['error'] ?? 'Room not found',
                style: text.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: Colors.red),
              tooltip: 'Clear',
            )
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECF3FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E6FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
              ),
            ),
            child: const Icon(Icons.meeting_room_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['roomName'] ?? 'Room',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Code: ${room['roomCode']}',
                  style: text.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onJoin,
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

/// ---------- Room Card ----------
class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.name,
    required this.code,
    required this.onTap,
  });

  final String name;
  final String code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAECEF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)],
                  ),
                ),
                child: const Icon(Icons.class_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: $code',
                      style: text.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- Skeleton while loading ----------
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = 120, double h = 12}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFFE9ECF2),
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE9ECF2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(w: 160, h: 14),
                const SizedBox(height: 8),
                bar(w: 100, h: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Empty state ----------
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.meeting_room_outlined,
                size: 88, color: Colors.black26),
            const SizedBox(height: 14),
            Text(
              title,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: text.bodyMedium?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
