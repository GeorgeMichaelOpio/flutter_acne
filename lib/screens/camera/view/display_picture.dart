import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:acne/route/screen_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Display the heavily blurred background image
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),

          // Add a slight dark overlay to make the foreground stand out more
          Container(
            color: Colors.black.withOpacity(0.2),
          ),

          // Position a white border box similar to camera preview
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 1.3,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.white.withOpacity(0.7), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              // Display the clear, focused image inside the box
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Instructions text at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 30,
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Review Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Camera button at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      scanDetailsScreenRoute,
                      arguments: {
                        'isProductAvailable': Random().nextInt(9).isEven,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                        16), // Adjust to match desired size
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/scan.svg",
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
