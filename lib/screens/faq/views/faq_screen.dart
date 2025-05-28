import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class FAQItem {
  final String question;
  final String answer;
  final String category;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _allFaqs = [];
  List<FAQItem> _filteredFaqs = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'General',
    'Detection',
    'Treatment',
    'App Usage',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFaqs();
    _filteredFaqs = _allFaqs;
  }

  void _initializeFaqs() {
    _allFaqs.addAll([
      // General Questions
      FAQItem(
        question: 'What is AcneDetect?',
        answer:
            'AcneDetect is a mobile application that uses AI technology to analyze your skin, detect acne conditions, and provide personalized treatment recommendations based on the severity and type of acne identified.',
        category: 'General',
      ),
      FAQItem(
        question: 'Is the app free to use?',
        answer:
            'The basic version of AcneDetect is free and includes limited scans per month. We offer a premium subscription that provides unlimited scans, detailed analytics, and personalized treatment plans.',
        category: 'General',
      ),
      FAQItem(
        question: 'Is my data secure?',
        answer:
            'We take your privacy seriously. All images and personal data are encrypted and stored securely. We do not share your information with third parties without your explicit consent. You can delete your data at any time from the settings menu.',
        category: 'General',
      ),

      // Detection Questions
      FAQItem(
        question: 'How accurate is the acne detection?',
        answer:
            'Our AI model has been trained on thousands of images and has an accuracy rate of approximately 90%. However, the app is designed as a supplementary tool and should not replace professional medical advice.',
        category: 'Detection',
      ),
      FAQItem(
        question: 'What types of acne can the app detect?',
        answer:
            'AcneDetect can identify several types of acne including whiteheads, blackheads, papules, pustules, nodules, and cysts. It can also assess the severity of your condition from mild to severe.',
        category: 'Detection',
      ),
      FAQItem(
        question: 'How should I take photos for the best results?',
        answer:
            'For optimal detection, take photos in good natural lighting, avoid using flash, keep your face clean and free of makeup, and capture multiple angles of the affected areas. The app will guide you through the process.',
        category: 'Detection',
      ),

      // Treatment Questions
      FAQItem(
        question: 'Are the treatment recommendations medically approved?',
        answer:
            'Our treatment suggestions are based on dermatological guidelines and research. However, they are general recommendations and not personalized medical prescriptions. Always consult a dermatologist for severe conditions.',
        category: 'Treatment',
      ),
      FAQItem(
        question: "Can I track my skin's progress over time?",
        answer:
            'Yes, the app includes a progress tracker that allows you to compare images and metrics over time to see how your skin is improving with treatment. Premium users get access to detailed analytics and trends.',
        category: 'Treatment',
      ),
      FAQItem(
        question: "What if the recommended treatments don't work for me?",
        answer:
            "Everyone's skin is unique, and what works for one person may not work for another. If you don't see improvement after 4-6 weeks, the app can suggest alternative treatments or recommend consulting a dermatologist.",
        category: 'Treatment',
      ),

      // App Usage Questions
      FAQItem(
        question: 'Can I use the app offline?',
        answer:
            'Some basic features of the app can be used offline, but the acne detection and analysis features require an internet connection to process images through our AI system.',
        category: 'App Usage',
      ),
      FAQItem(
        question: 'How do I export my skin analysis report?',
        answer:
            'You can export your skin analysis report by going to the History section, selecting the analysis you want to export, and tapping the Share icon. You can export it as a PDF or share it directly with your healthcare provider.',
        category: 'App Usage',
      ),
      FAQItem(
        question: 'How often should I scan my skin?',
        answer:
            'For the best tracking results, we recommend scanning your skin once a week. Acne treatments typically take several weeks to show results, so frequent scanning helps monitor progress effectively.',
        category: 'App Usage',
      ),
    ]);
  }

  void _filterFaqs(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredFaqs = _allFaqs;
      } else {
        _filteredFaqs =
            _allFaqs.where((faq) {
              final matchesCategory =
                  _selectedCategory == 'All' ||
                  faq.category == _selectedCategory;
              final matchesQuery =
                  query.isEmpty ||
                  faq.question.toLowerCase().contains(query.toLowerCase()) ||
                  faq.answer.toLowerCase().contains(query.toLowerCase());
              return matchesCategory && matchesQuery;
            }).toList();
      }
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterFaqs(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "FAQs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Feather.help_circle),
            onPressed: () => _showTipDialog(context),
            tooltip: 'Tips for using AcneDetect',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(child: _buildFaqList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search questions...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Ionicons.search_outline, color: Colors.grey[500]),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Ionicons.close_outline, color: Colors.grey[500]),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _filterFaqs('');
                      });
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: _filterFaqs,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
              ),
            ),
            selected: isSelected,
            onSelected: (selected) => _selectCategory(category),
            backgroundColor: Colors.grey[200],
            selectedColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildFaqList() {
    return _filteredFaqs.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Ionicons.search_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or select another category',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        )
        : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: _filteredFaqs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildFaqItem(_filteredFaqs[index]),
        );
  }

  Widget _buildFaqItem(FAQItem faq) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: faq.isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            faq.isExpanded = expanded;
          });
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            faq.isExpanded ? Ionicons.chevron_up : Ionicons.chevron_down,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(faq.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  faq.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getCategoryColor(faq.category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thanks for your feedback!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16),
                    SizedBox(width: 4),
                    Text('Helpful'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'General':
        return Colors.blue;
      case 'Detection':
        return Colors.green;
      case 'Treatment':
        return Colors.orange;
      case 'App Usage':
        return Colors.purple;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  void _showTipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Ionicons.bulb_outline,
                      size: 24,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Quick Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildTipItems(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTipItems() {
    return [
      _buildTipItem(
        icon: Ionicons.camera_outline,
        title: 'Take Photos in Good Lighting',
        subtitle: 'Natural daylight works best for accurate detection.',
      ),
      const Divider(height: 24),
      _buildTipItem(
        icon: Ionicons.happy_outline,
        title: 'Clean Your Face',
        subtitle: 'Remove makeup and cleanse before scanning.',
      ),
      const Divider(height: 24),
      _buildTipItem(
        icon: Ionicons.calendar_outline,
        title: 'Scan Weekly',
        subtitle: 'Regular scanning helps track your progress effectively.',
      ),
      const Divider(height: 24),
      _buildTipItem(
        icon: Ionicons.settings_outline,
        title: 'Calibrate Your Camera',
        subtitle: 'Use the calibration tool for optimal results.',
      ),
    ];
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
