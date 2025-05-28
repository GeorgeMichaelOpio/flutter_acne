import 'package:flutter/material.dart';
import '../../../constants.dart';

class AcneDetectionHelpScreen extends StatelessWidget {
  const AcneDetectionHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildHelpSection(
              context,
              title: "Using the App",
              icon: Icons.face_retouching_natural,
              children: [
                _buildStep(
                  context,
                  number: "1",
                  title: "Take or Upload a Photo",
                  description:
                      "Tap the camera button to capture a new photo or select an existing one from your gallery.",
                  icon: Icons.camera_alt_rounded,
                ),
                _buildStep(
                  context,
                  number: "2",
                  title: "Position Your Face",
                  description:
                      "Ensure your face is well-lit and centered within the frame for optimal analysis.",
                  icon: Icons.center_focus_strong,
                ),
                _buildStep(
                  context,
                  number: "3",
                  title: "Review Analysis",
                  description:
                      "The app will highlight acne areas and provide a detailed severity assessment.",
                  icon: Icons.analytics,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHelpSection(
              context,
              title: "Tips for Best Results",
              icon: Icons.auto_awesome,
              children: [
                _buildTip(
                  context,
                  icon: Icons.light_mode,
                  title: "Optimal Lighting",
                  description:
                      "Natural daylight provides the most accurate results. Avoid shadows on your face.",
                  color: Colors.amber.shade100,
                ),
                _buildTip(
                  context,
                  icon: Icons.clean_hands,
                  title: "Clear Skin Surface",
                  description:
                      "Remove makeup and cleanse your face before analysis for best results.",
                  color: Colors.blue.shade50,
                ),
                _buildTip(
                  context,
                  icon: Icons.timelapse,
                  title: "Consistent Tracking",
                  description:
                      "Take photos at the same time each day to monitor treatment progress effectively.",
                  color: Colors.green.shade50,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHelpSection(
              context,
              title: "Understanding Results",
              icon: Icons.insights,
              children: [
                _buildSeverityCard(
                  context,
                  title: "Mild Acne",
                  description:
                      "Few pimples or blackheads, typically not inflamed.",
                  level: "Mild",
                  color: Colors.green,
                  percentage: "0-30%",
                ),
                _buildSeverityCard(
                  context,
                  title: "Moderate Acne",
                  description: "More visible pimples with some inflammation.",
                  level: "Moderate",
                  color: Colors.orange,
                  percentage: "30-60%",
                ),
                _buildSeverityCard(
                  context,
                  title: "Severe Acne",
                  description:
                      "Many inflamed pimples, possibly cystic acne requiring medical attention.",
                  level: "Severe",
                  color: Colors.red,
                  percentage: "60-100%",
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildHelpSection(
              context,
              title: "Important Notes",
              icon: Icons.warning_rounded,
              children: [
                _buildNote(
                  context,
                  "This tool provides preliminary assessment only and is not a substitute for professional medical advice.",
                ),
                _buildNote(
                  context,
                  "Your skin images are stored securely on your device and can be deleted anytime from History.",
                ),
                _buildNote(
                  context,
                  "For persistent or severe acne, consult a dermatologist. Find nearby clinics in the 'Pharmacies' section.",
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: primaryColor.withOpacity(0.3),
                ),
                child: const Text(
                  "Got It!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, size: 32, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Follow these guidelines to get the most accurate acne analysis from your photos.",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityCard(
    BuildContext context, {
    required String title,
    required String description,
    required String level,
    required Color color,
    required String percentage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  level,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getProgressValue(percentage),
                  backgroundColor: Colors.grey.shade200,
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Coverage: $percentage",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getProgressValue(String percentage) {
    final range = percentage.replaceAll("%", "").split("-");
    if (range.length == 2) {
      return (int.parse(range[1]) / 100);
    }
    return 0.3; // default value
  }

  Widget _buildNote(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
