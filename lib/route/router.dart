import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => RegisterScreen(),
      );
    case cameraScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;
      final cameras = args['cameras'] as List<CameraDescription>;
      final initialCamera = args['initialCamera'] as CameraDescription;
      return MaterialPageRoute(
        builder: (context) => ScanProductsScreen(
          cameras: cameras,
          initialCamera: initialCamera,
        ),
      );
    case productDetailsScreenRoute:
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      Map<String, dynamic>? scanData = args['scanData'];
      return MaterialPageRoute(
        builder: (context) {
          return AcneDetailsScreen(
            scanData: scanData,
          );
        },
      );
    case scanDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final args = settings.arguments as Map<String, dynamic>;
          return ScanDetailsScreen(
            scanData: args['scanData'],
            imagePath: args['imagePath'],
          );
        },
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case historyScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => UserInfoScreen(),
      );
    case preferencesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PreferencesScreen(),
      );
    default:
      return MaterialPageRoute(
        // Make a screen for undefine
        builder: (context) => const HomeScreen(),
      );
  }
}
