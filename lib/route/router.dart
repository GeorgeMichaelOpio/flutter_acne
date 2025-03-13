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
      bool isProductAvailable = args['isProductAvailable'] ?? true;
      return MaterialPageRoute(
        builder: (context) {
          return AcneDetailsScreen(
            isProductAvailable: isProductAvailable,
          );
        },
      );
    case scanDetailsScreenRoute:
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      bool isProductAvailable = args['isProductAvailable'] ?? true;
      return MaterialPageRoute(
        builder: (context) {
          return ScanDetailsScreen(
            isProductAvailable: isProductAvailable,
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
        builder: (context) => const UserInfoScreen(),
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
