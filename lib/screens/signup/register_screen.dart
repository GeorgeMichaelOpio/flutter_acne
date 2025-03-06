import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../components/card.dart';
import '../../route/route_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisibility = !_passwordVisibility;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _confirmPasswordVisibility = !_confirmPasswordVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color:
              Color(0xFF8A2BE2), // Rich purple color like in the login screen
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // GlassMorphismCover for the register card
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
                                    return "Please enter your email";
                                  }
                                  // Basic email validation
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return "Please enter a valid email";
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
                                    return "Please enter a password";
                                  }
                                  if (value.length < 6) {
                                    return "Password must be at least 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_confirmPasswordVisibility,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisibility
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: _toggleConfirmPasswordVisibility,
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
                                    return "Please confirm your password";
                                  }
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),

                              // Error Message
                              if (authProvider.error.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    authProvider.error,
                                    style: TextStyle(color: Colors.red[800]),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              // Register Button
                              ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final success = await authProvider
                                              .registerWithEmailAndPassword(
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
                                    : Text('REGISTER'),
                              ),

                              // Login Link
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, 'login');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                child: Text('LOGIN'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Google Sign-up Button
                    ElevatedButton.icon(
                      icon: Icon(Icons.g_mobiledata, size: 24),
                      label: Text('Sign up with Google'),
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
                    ),
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
