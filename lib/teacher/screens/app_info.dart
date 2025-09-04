import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Legal & About',
          style: TextStyle(color: Colors.white),
        ),
        // ====================== COLOR CHANGED HERE ======================
        backgroundColor: Colors.indigo,
        // ================================================================
        foregroundColor: Colors.white, // makes icons (like back button) white
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Terms of Use'),
            Tab(text: 'Privacy Policy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AboutTab(),
          _TermsTab(),
          _PrivacyPolicyTab(),
        ],
      ),
    );
  }
}

// Reusable helper widgets
Widget _buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5)),
  );
}

Widget _buildFeatureItem(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
}


// ====================== 'ABOUT' TAB COMPLETELY REVAMPED ======================
class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Welcome to PSU Quiz App! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildParagraph(
              'Our mission is to make learning more interactive, efficient, and engaging. We\'ve created a simple yet powerful platform to bridge the gap between teaching and assessment.'),
          
          _buildSectionTitle(context, 'How It Works'),
          _buildParagraph('Our platform is built around a simple, code-based room system that connects teachers and students seamlessly.'),
          _buildFeatureItem(
            context,
            icon: Icons.create_rounded,
            title: 'For Teachers 🧑‍🏫',
            subtitle: 'Easily create custom quizzes, organize them into a dedicated "room", and share the unique room code with your students.'
          ),
          _buildFeatureItem(
            context,
            icon: Icons.login_rounded,
            title: 'For Students 🎓',
            subtitle: 'Simply enter the room code provided by your teacher to join. Take the quiz and receive your results instantly upon completion.'
          ),

          _buildSectionTitle(context, 'Key Features'),
          _buildFeatureItem(
            context,
            icon: Icons.feedback_rounded,
            title: 'Instant Feedback',
            subtitle: 'See your score and review your answers immediately after finishing a quiz.'
          ),
          _buildFeatureItem(
            context,
            icon: Icons.edit_note_rounded,
            title: 'Custom Quizzes',
            subtitle: 'Teachers can create quizzes that align perfectly with their curriculum for relevant practice.'
          ),
          _buildFeatureItem(
            context,
            icon: Icons.phone_android_rounded,
            title: 'Simple & Intuitive',
            subtitle: 'A clean, user-friendly interface designed for everyone. No complicated setups.'
          ),
          
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Our goal is to create a seamless link between teaching and learning. Happy quizzing!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
// ==============================================================================

// --- Terms Tab Content (Unchanged) ---
class _TermsTab extends StatelessWidget {
  const _TermsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Last Updated: September 5, 2025', style: TextStyle(fontStyle: FontStyle.italic)),
          _buildSectionTitle(context, '1. Accounts'),
          _buildParagraph('When you create an account, you must provide accurate information. You are responsible for safeguarding your password and for any activities under your account.'),
          _buildSectionTitle(context, '2. User Content'),
          _buildParagraph('If you are a Teacher, you are responsible for the content (quizzes, questions) you create. You grant us a license to display and distribute your content for the purpose of operating the Service.'),
          _buildSectionTitle(context, '3. Acceptable Use'),
          _buildParagraph('You agree not to use the Service for any unlawful purpose, to cheat, or to engage in any form of academic dishonesty.'),
          _buildSectionTitle(context, '4. Termination'),
          _buildParagraph('We may terminate or suspend your account without notice if you breach these Terms.'),
          _buildSectionTitle(context, '5. Contact Us'),
          _buildParagraph('If you have any questions about these Terms, please contact us at contact@psuquizapp.com.'),
        ],
      ),
    );
  }
}

// --- Privacy Policy Tab Content (Unchanged) ---
class _PrivacyPolicyTab extends StatelessWidget {
  const _PrivacyPolicyTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Last Updated: September 5, 2025', style: TextStyle(fontStyle: FontStyle.italic)),
          _buildSectionTitle(context, 'Information We Collect'),
          _buildParagraph('• Personal Data: Your name/username, email address, and role (Teacher/Student).\n\n• User-Generated Data: Quizzes created by Teachers and answers/scores submitted by Students.'),
          _buildSectionTitle(context, 'How We Use Your Data'),
          _buildParagraph('We use your data to provide the Service, including authenticating users, delivering quizzes, and calculating results. We do not sell your personal data.'),
          _buildSectionTitle(context, 'Data Sharing'),
          _buildParagraph('A Teacher can view the results of Students who complete tests in their rooms. We may use third-party services (like cloud hosting) to operate the app.'),
          _buildSectionTitle(context, 'Data Security'),
          _buildParagraph('We strive to use commercially acceptable means to protect your data, but no method is 100% secure.'),
          _buildSectionTitle(context, 'Contact Us'),
          _buildParagraph('If you have any questions about this Privacy Policy, please contact us at privacy@psuquizapp.com.'),
        ],
      ),
    );
  }
}