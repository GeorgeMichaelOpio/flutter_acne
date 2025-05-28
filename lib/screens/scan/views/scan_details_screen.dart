import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:lottie/lottie.dart';

import '../../../auth_provider.dart';
import '../../../constants.dart';
import '../../../scan_provider.dart';
import 'components/acne_images.dart';
import 'components/acne_info.dart';
import 'components/acne_list_tile.dart';

class ScanDetailsScreen extends StatelessWidget {
  const ScanDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    this.scanData,
    required this.imagePath,
  });

  final bool isProductAvailable;
  final Map<String, dynamic>? scanData;
  final String imagePath;

  // Function to show loading dialog
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

  // Function to show error snackbar
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

  // Function to show success snackbar
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

  // Function to download image from URL and save to temp directory
  Future<String> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final fileName = p.basename(url);
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // Function to upload image to Supabase storage
  Future<String?> _uploadImageToStorage(String filePath, String userId) async {
    try {
      final file = File(filePath);
      final fileName = p.basename(filePath);
      final fileExtension = p.extension(fileName);
      final uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Upload to user's folder in storage
      final uploadPath = '$userId/$uniqueFileName';

      await Supabase.instance.client.storage
          .from('scan-images')
          .upload(uploadPath, file);

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('scan-images')
          .getPublicUrl(uploadPath);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to save data to Supabase with images
  Future<void> _saveToSupabase(BuildContext context) async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    Provider.of<AuthProvider>(context, listen: false);
    final Session? session = Supabase.instance.client.auth.currentSession;
    final User? currentUser = Supabase.instance.client.auth.currentUser;

    if (session == null || currentUser == null) {
      _showErrorSnackBar(context, 'You need to be signed in to save scans');
      return;
    }

    // Show loading dialog
    _showLoadingDialog(context);

    try {
      final String userId = currentUser.id;

      // Upload original image to storage
      final uploadedImageUrl = await _uploadImageToStorage(imagePath, userId);
      String? scannedImageUrl;

      if (scanData?['fileInfo']?['url'] != null) {
        // If the scanned image is a URL, download it first
        if (scanData!['fileInfo']['url'].startsWith('http')) {
          // Download the image first
          final downloadedPath = await _downloadImage(
            scanData!['fileInfo']['url'],
          );
          // Then upload to Supabase
          scannedImageUrl = await _uploadImageToStorage(downloadedPath, userId);
          // Delete the temporary file
          await File(downloadedPath).delete();
        } else {
          // It's a local file, upload directly
          scannedImageUrl = await _uploadImageToStorage(
            scanData!['fileInfo']['url'],
            userId,
          );
        }
      }

      if (uploadedImageUrl == null) {
        throw Exception('Failed to upload original image');
      }

      // Prepare data to save
      final Map<String, dynamic> dataToSave = {
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'original_image_url': uploadedImageUrl,
        'scanned_image_url': scannedImageUrl,
        'prediction': scanData!['prediction'],
        'spots': scanData!['spots'],
        'report': scanData!['report'],
        'user_id': userId,
      };

      // Insert the scan into the 'scans' table
      await Supabase.instance.client.from('scans').insert(dataToSave);

      // Refresh the scans list in the provider
      await scanProvider.fetchUserScans(userId);

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show success message
      _showSuccessSnackBar(context, 'Scan saved successfully');
    } catch (e) {
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      _showErrorSnackBar(context, 'Failed to save scan,Please try again');
      print('Error saving to Supabase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var fileInfo = scanData!['fileInfo'];
    var prediction = scanData!['prediction'];
    var spots = scanData!['spots'];
    var report = scanData!['report'];

    // Extract image URL from the response
    String imageUrl = fileInfo['url'] ?? '';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed:
                      () => {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          'entry_point',
                          (route) => false,
                        ),
                      },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      "assets/icons/home.svg",
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _saveToSupabase(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(
                      "assets/icons/save.svg",
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            AcneImages(images: [imagePath]),
            ProductInfo(
              brand: DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc()),
              isAvailable: spots > 0 ? isProductAvailable : false,
              description:
                  spots > 0
                      ? "Based on the image provided, ${prediction['label']} was found"
                      : "Based on the image provided, no acne was detected",
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
      appBar: AppBar(title: const Text('Scan Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          child: Markdown(
            data: report,
            styleSheet: MarkdownStyleSheet(
              h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              p: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
