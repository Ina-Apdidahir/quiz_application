import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoPage extends StatelessWidget {
  const DeveloperInfoPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Professional gradient (replace all solid blue with this)
  LinearGradient get _blueGradient => const LinearGradient(
        colors: [
          Color(0xFF3B82F6), // Tailwind blue-500
          Color(0xFF2563EB), // Tailwind blue-500
          Color.fromARGB(255, 60, 112, 225), // Tailwind blue-600
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Developer Info"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _blueGradient),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Profile Card with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: _blueGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Developer Image with Rounded Stroke
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage("assets/images/developer.jpg"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Bishar Abdidahir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "As a skilled full-stack developer, I specialize in creating robust and scalable applications. My primary tools include:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tech Stack Icons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18.0,
                      runSpacing: 18.0,
                      children: [
                        _buildTechIcon("assets/icons/postgresql.svg"),
                        _buildTechIcon("assets/icons/nodedotjs.svg"),
                        _buildTechIcon("assets/icons/flutter.svg"),
                        _buildTechIcon("assets/icons/javascript.svg"),
                        _buildTechIcon("assets/icons/nextdotjs.svg"),
                        _buildTechIcon("assets/icons/flask.svg"),
                        _buildTechIcon("assets/icons/react.svg"),
                        _buildTechIcon("assets/icons/mongodb.svg"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildActionCard(
                    iconWidget: const FaIcon(FontAwesomeIcons.whatsapp,
                        color: Colors.green, size: 24),
                    text: "WhatsApp",
                    onTap: () => _launchUrl("https://wa.me/qr/55ESSQG4QYUOB1"),
                  ),
                  const SizedBox(height: 15),
                  _buildActionCard(
                    iconWidget: const FaIcon(FontAwesomeIcons.github,
                        color: Colors.black, size: 24),
                    text: "GitHub",
                    onTap: () => _launchUrl("https://github.com/Ina-Apdidahir"),
                  ),
                  const SizedBox(height: 15),
                  _buildActionCard(
                    iconWidget: const FaIcon(FontAwesomeIcons.linkedin,
                        color: Color(0xFF0A66C2), size: 24),
                    text: "LinkedIn",
                    onTap: () => _launchUrl("https://linkedin.com/in/ismail"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechIcon(String assetPath, {Color bgColor = Colors.white}) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(assetPath, height: 28, width: 28),
      ),
    );
  }

  Widget _buildActionCard({
    Widget? iconWidget,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            iconWidget ?? const Icon(Icons.person, size: 26),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
