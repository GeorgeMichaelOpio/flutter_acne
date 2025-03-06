import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    this.isProductAvailable = true,
    this.showSaveButton = true,
    this.scanData,
  });

  final bool isProductAvailable;
  final bool showSaveButton;
  final Map<String, dynamic>? scanData;

  // Function to save data to Firestore with proper authentication check
  Future<void> _saveToFirestore(BuildContext context) async {
    // Check if user is signed in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Show error if not signed in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be signed in to save scans'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final String userId = currentUser.uid;
      final String scanDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Prepare data to save
      final Map<String, dynamic> dataToSave = {
        "scan_date": scanDate,
        "image_url": scanData?["image_url"] ?? "",
        "scanned_image_url": scanData?["scanned_image_url"] ?? "",
        "number_of_spots": scanData?["number_of_spots"] ?? "0",
        "type_of_acne": scanData?["type_of_acne"] ?? [],
        "recommended_treatment": scanData?["recommended_treatment"] ?? "",
        "timestamp": FieldValue.serverTimestamp(),
      };

      // First check if the user document exists, if not create it
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // Create the user document first
        await userDocRef.set({
          'created_at': FieldValue.serverTimestamp(),
          'email': currentUser.email ?? 'No email',
        });
      }

      // Add the scan to the user's scans subcollection
      await userDocRef.collection('scans').add(dataToSave);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving scan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                if (showSaveButton)
                  IconButton(
                    onPressed: () => _saveToFirestore(context),
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
            const ProductImages(
              images: [productDemoImg1, productDemoImg2],
            ),
            ProductInfo(
              brand: "LIPSY LONDON",
              title: "Sleeveless Ruffle",
              isAvailable: isProductAvailable,
              description:
                  "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you're supporting more responsibly...",
            ),
            ProductListTile(
              svgSrc: "assets/icons/Scan.svg",
              title: "Scan Details",
              press: () {},
            ),
            ProductListTile(
              svgSrc: "assets/icons/treatment.svg",
              title: "Recommended Treatment",
              press: () {},
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
