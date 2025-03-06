import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'route/screen_export.dart';
import 'theme/app_theme.dart';
import 'theme/provider/theme_provider.dart';
import '/route/router.dart' as router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();

  while (!authProvider.initialCheckCompleted) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  runApp(MyApp(authProvider: authProvider, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final ThemeProvider themeProvider;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, child) {
          if (auth.isLoading || theme.isLoading) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Acne',
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            home: _buildInitialScreen(auth),
            onGenerateRoute: router.generateRoute,
          );
        },
      ),
    );
  }

  Widget _buildInitialScreen(AuthProvider auth) {
    return auth.isAuthenticated ? const EntryPoint() : LoginScreen();
  }
}
