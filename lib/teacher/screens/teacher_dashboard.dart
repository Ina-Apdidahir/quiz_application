import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_application/models/user_model.dart';
import 'package:quiz_application/teacher/screens/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/analysis_api.dart';
import '../../api/auth_api.dart';
import '../../models/analysis_model.dart';
import '../../screens/rooms/rooms_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../teacher/screens/app_license_screen.dart';
import '../../teacher/screens/app_setting_screen.dart';
import '../../teacher/screens/developer_info_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  Analysis? teacherAnalysis;
  User? _currentUser;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // For navigation
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    // Placeholder for dashboard content (will be handled by the main body)
    SizedBox(),
    ProfileScreen(),
    DeveloperInfoPage(),
    // AppSettingsPage(),
    InfoPage(),
  ];

  final List<String> _titles = const [
    "Dashboard",
    "Profile",
    "Developer Info",
    // "Settings",
    // "App License",
    "About Us",
  ];

  final Color _primary = const Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("No token found in SharedPreferences");
      }

      // Fetch both analysis and user data concurrently
      final analysisRes = await AnalysisApi.fetchTeacherAnalysis();
      final userDataResponse = await AuthApi.getUserData(token);

      if (userDataResponse['success'] == true &&
          userDataResponse['userData'] != null) {
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(userDataResponse['userData']);

        // Remap user field
        if (userData.containsKey('user')) {
          userData['id'] = userData['user'];
        }

        final user = User.fromJson(userData);

        setState(() {
          teacherAnalysis = analysisRes;
          _currentUser = user;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          teacherAnalysis = analysisRes;
          _currentUser = null;
        });
        debugPrint(
            'Failed to fetch user data: ${userDataResponse['error'] ?? "Unknown error"}');
      }
    } catch (e, stack) {
      debugPrint('Failed to fetch dashboard data: $e\n$stack');
      setState(() {
        isLoading = false;
        teacherAnalysis = null;
        _currentUser = null;
      });
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

  // Drawer builder method
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_currentUser?.name ?? "Teacher"),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (teacherAnalysis == null || _currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load dashboard data.")),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 180,
            elevation: 0,
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            title: const Text(
              'Teacher Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            // actions: [
            //   IconButton(
            //     onPressed: _fetchDashboardData,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Use the fetched username
                        Text(
                          "Welcome, ${_currentUser?.name ?? 'Teacher'}!",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Here is a quick overview of your dashboard.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate(
                [
                  _buildStatCard(
                      "All Tests", teacherAnalysis!.allTests, Icons.assignment),
                  _buildStatCard("Total Students",
                      teacherAnalysis!.totalStudents, Icons.people),
                  _buildStatCard("My Rooms", teacherAnalysis!.totalRooms,
                      Icons.meeting_room),
                  _buildButtonCard("Manage Rooms", Icons.settings, () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RoomsScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(count.toString(),
                style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonCard(String label, IconData icon, VoidCallback onTap) {
    return Card(
      color: Colors.indigo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
