import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Add this import for Lottie animations

import '../../../auth_provider.dart';
import '../../../constants.dart';
import '../../../scan_provider.dart';
import 'components/acne_images.dart';
import 'components/acne_info.dart';
import 'components/acne_list_tile.dart';

class AcneDetailsScreen extends StatelessWidget {
  const AcneDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    this.scanData,
    this.scanId,
  });

  final bool isProductAvailable;
  final Map<String, dynamic>? scanData;
  final int? scanId;

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Lottie.asset('assets/animations/loading.json'),
              ),
            ),
          ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  Future<void> _deleteScan(BuildContext context) async {
    final scanId = scanData?['id'];
    if (scanId == null) return;

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Show confirmation dialog
      final confirmed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.2),
            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete Scan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This will permanently remove the scan. You cannot undo this action.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Delete',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      if (confirmed != true) return;

      // Show loading dialog
      _showLoadingDialog(context);

      final success = await scanProvider.deleteScan(
        scanId,
        authProvider.user!.id,
      );

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      if (success) {
        _showSuccessSnackBar(context, 'Scan deleted successfully');
        // Navigate back to previous screen
        Navigator.pop(context);
      } else {
        _showErrorSnackBar(context, "Failed to delete scan");
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context, rootNavigator: true).pop();
      _showErrorSnackBar(
        context,
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var fileInfo = scanData!['fileInfo'];
    var prediction = scanData!['prediction'];
    var spots = scanData!['spots'];
    var report = scanData!['report'];

    // Extract image URL from the response
    String imageUrl1 = fileInfo['url1'] ?? '';
    String imageUrl2 = fileInfo['url2'] ?? '';
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () => _deleteScan(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      "assets/icons/delete.svg",
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            AcneImages(images: [imageUrl1]),
            ProductInfo(
              brand: DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc()),
              isAvailable: spots > 0 ? isProductAvailable : false,
              description:
                  spots > 0
                      ? "Based on the image provided,${prediction['label']} was found"
                      : "Base on the image provide detected acne was not found",
            ),
            if (spots > 0) ...[
              AcneListTile(
                svgSrc: "assets/icons/Scan.svg",
                title: "Scan Details",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkdownScreen(report: report),
                    ),
                  );
                },
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
          ],
        ),
      ),
    );
  }
}

class MarkdownScreen extends StatelessWidget {
  final String report;

  const MarkdownScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          child: Markdown(
            data: report,
            styleSheet: MarkdownStyleSheet(
              h1: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              h2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              h3: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              p: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
