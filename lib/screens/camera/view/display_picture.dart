import 'dart:io';
import 'dart:math';
import 'dart:ui';
import '/route/screen_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _analyzeSkin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://acne-api.onrender.com/predict'),
      );

      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        widget.imagePath,
      ));

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(responseData);
        Map<String, dynamic> result = {
          'fileInfo': jsonResponse[0],
          'prediction': jsonResponse[1],
          'spots': jsonResponse[2],
          'report': jsonResponse[3],
        };

        print(result);

        // Navigate to ScanDetailsScreen with the result data
        Navigator.pushNamed(
          context,
          scanDetailsScreenRoute,
          arguments: {
            'scanData': result,
            'imagePath': widget.imagePath,
          },
        );
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
        });
        _showErrorSnackBar('Failed to analyze image. Please try again.');
      }
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _isLoading = false;
      });
      _showErrorSnackBar(
          'Could not connect to the analysis server. Please check your connection and try again.');
    }
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

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
              File(widget.imagePath),
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
                  File(widget.imagePath),
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
                  onTap: _isLoading ? null : _analyzeSkin,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.black.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : SvgPicture.asset(
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
