import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../components/card.dart';
import '../../route/route_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisibility = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisibility = !_passwordVisibility;
    });
  }

  // Show error message using ScaffoldMessenger
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[800],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Show auth provider errors via ScaffoldMessenger
    if (authProvider.error.isNotEmpty) {
      // Use a post-frame callback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorMessage(authProvider.error);
        // Clear the error after showing it
        authProvider.clearError();
      });
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF8A2BE2), // Rich purple color like in the image
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GlassMorphismCover for the login card
                    GlassMorphismCover(
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                autofocus: false,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey[500],
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // Return null as we'll show via SnackBar
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisibility,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisibility
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: _togglePasswordVisibility,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // Return null as we'll show via SnackBar
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),

                              // Login Button
                              ElevatedButton(
                                // Inside the onPressed handler of the ElevatedButton
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        bool isValid =
                                            _formKey.currentState!.validate();

                                        // Check for empty fields and show messages via ScaffoldMessenger
                                        final emailEmpty =
                                            _emailController.text.isEmpty;
                                        final passwordEmpty =
                                            _passwordController.text.isEmpty;

                                        if (emailEmpty && passwordEmpty) {
                                          _showErrorMessage(
                                              "Please enter your email and password");
                                          isValid = false;
                                        } else {
                                          if (emailEmpty) {
                                            _showErrorMessage(
                                                "Please enter your email");
                                            isValid = false;
                                          }
                                          if (passwordEmpty) {
                                            _showErrorMessage(
                                                "Please enter your password");
                                            isValid = false;
                                          }
                                        }

                                        if (isValid) {
                                          final success = await authProvider
                                              .signInWithEmailAndPassword(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                          if (success && mounted) {
                                            Navigator.pushNamed(
                                                context, entryPointScreenRoute);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF8A2BE2),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(120, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text('LOGIN'),
                              ),

                              // Signup Link
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "signup");
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                child: Text('SIGNUP'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Google Sign-in Button
                    ElevatedButton.icon(
                      icon: Icon(Icons.g_mobiledata, size: 24),
                      label: Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(20, 44), // Make it full width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final success =
                                  await authProvider.signInWithGoogle();
                              if (success && mounted) {
                                Navigator.pushNamed(
                                    context, entryPointScreenRoute);
                              }
                            },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// You would need to add this method to your AuthProvider class
extension AuthProviderExtension on AuthProvider {
  void clearError() {
    // Implement this method in your AuthProvider class
    // to clear the error message after displaying it
  }
}
