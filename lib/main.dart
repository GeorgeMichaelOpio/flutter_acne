import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';
import 'scan_provider.dart';
import 'route/screen_export.dart';
import 'theme/app_theme.dart';
import 'theme/provider/theme_provider.dart';
import 'route/router.dart' as router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zxiropcgpjxccwbnpigw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp4aXJvcGNncGp4Y2N3Ym5waWd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwNDQzNTEsImV4cCI6MjA2MDYyMDM1MX0.Yz7SlJ6BU7d342hZ9v3tX8dSSGh6ZUD2Vn3oszybzk4',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ScanProvider>(
          create: (context) => ScanProvider(),
          update: (context, authProvider, scanProvider) {
            if (authProvider.isAuthenticated) {
              // Only fetch scans if we have a user and scans haven't been loaded yet
              if (scanProvider?.scans.isEmpty ?? true) {
                scanProvider?.fetchUserScans(authProvider.user!.id);
              }
            } else {
              // Clear scans when logged out
              scanProvider?.resetScans(); // Use the public method
            }
            return scanProvider!;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeProvider>();
          final auth = context.watch<AuthProvider>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Acne',
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            home:
                auth.isAuthenticated ? const EntryPoint() : const LoginScreen(),
            onGenerateRoute: router.generateRoute,
          );
        },
      ),
    );
  }
}
