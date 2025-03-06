import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import 'display_picture.dart';

class ScanProductsScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraDescription initialCamera;

  const ScanProductsScreen({
    super.key,
    required this.cameras,
    required this.initialCamera,
  });

  @override
  State<ScanProductsScreen> createState() => _ScanProductsScreenState();
}

class _ScanProductsScreenState extends State<ScanProductsScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late CameraDescription _selectedCamera;

  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _selectedCamera = widget.initialCamera;
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      _selectedCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    if (_controller != null && _controller!.value.isInitialized) {
      _isFlashOn = !_isFlashOn;
      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    final newCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection != _selectedCamera.lensDirection,
    );
    _selectedCamera = newCamera;
    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      _navigateToDisplayScreen(image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take picture: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _navigateToDisplayScreen(image.path);
    }
  }

  void _navigateToDisplayScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
        actions: [
          Container(
            // Camera button with circle
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.photo_library_outlined, color: Colors.white),
              iconSize: 35,
              onPressed: _pickImageFromGallery,
            ),
          )
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
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
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Take ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          TextSpan(
                            text: 'Clear image ',
                            style: TextStyle(
                              color: Colors.lightGreenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 1.3,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white.withOpacity(0.7), width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCameraButton(
                        icon: _isFlashOn
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        onPressed: _toggleFlash,
                      ),
                      const SizedBox(width: 32),
                      Container(
                        // Camera button with circle
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildCameraButton(
                        icon: Icons.cameraswitch,
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Camera error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCameraButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.4),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }
}
