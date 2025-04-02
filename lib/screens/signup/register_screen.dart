import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../components/card.dart';
import '../../route/route_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Lottie.asset(
                'assets/animations/loading.json'),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister(AuthProvider auth) async {
    auth.clearError();
    if (!_formKey.currentState!.validate()) return;

    _showLoadingDialog(context);

    final success = await auth.registerWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) Navigator.pop(context); // Dismiss loading dialog

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, entryPointScreenRoute);
    } else if (mounted && auth.error.isNotEmpty) {
      _showErrorSnackBar(auth.error);
    }
  }

  Future<void> _handleGoogleRegister(AuthProvider auth) async {
    auth.clearError();

    _showLoadingDialog(context);

    final success = await auth.signInWithGoogle();

    if (mounted) Navigator.pop(context); // Dismiss loading dialog

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, entryPointScreenRoute);
    } else if (mounted && auth.error.isNotEmpty) {
      _showErrorSnackBar(auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8A2BE2),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GlassMorphismCover(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildEmailField(),
                            const SizedBox(height: 10),
                            _buildPasswordField(),
                            const SizedBox(height: 10),
                            _buildConfirmPasswordField(),
                            const SizedBox(height: 16),
                            _buildRegisterButton(auth),
                            const SizedBox(height: 16),
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGoogleButton(auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintText: "Email",
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return "Please enter your email";
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return "Please enter a valid email";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisibility,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
        hintText: "Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisibility
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: () =>
              setState(() => _passwordVisibility = !_passwordVisibility),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return "Please enter a password";
        if (value!.length < 6) return "Password must be at least 6 characters";
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_confirmPasswordVisibility,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red),
        ),
        hintText: "Confirm Password",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_confirmPasswordVisibility
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: () => setState(
              () => _confirmPasswordVisibility = !_confirmPasswordVisibility),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return "Please confirm your password";
        if (value != _passwordController.text) return "Passwords don't match";
        return null;
      },
    );
  }

  Widget _buildRegisterButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: auth.isLoading ? null : () => _handleRegister(auth),
        child: const Text(
          'REGISTER',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () =>
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false),
      child: Column(children: [
        const Text(
          "Already have an account?",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const Text(
          "LOGIN",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        )
      ]),
    );
  }

  Widget _buildGoogleButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Sign up with Google'),
        onPressed: auth.isLoading ? null : () => _handleGoogleRegister(auth),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
