import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/show_snackbar.dart';
import '../widgets/filled_text_field.dart';
import '../screens/sign_in_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp(AuthProviders authProvider) async {
    if (passwordController.text == confirmPasswordController.text) {
      String? errorMessage = await authProvider.signUp(
        emailController.text,
        passwordController.text,
      );

      if (errorMessage == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          showSnackBar('Sign-up successful! Please sign in.'),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          showSnackBar(errorMessage),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        showSnackBar('Passwords do not match'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Form(
          key: formKey,
          child: Container(
            margin: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  FilledTextField(
                    controller: emailController,
                    labelText: 'Enter your email',
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  FilledTextField(
                    controller: passwordController,
                    labelText: 'Enter your password',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  FilledTextField(
                    controller: confirmPasswordController,
                    labelText: 'Confirm your password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (authProvider.isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () => _signUp(authProvider),
                      child: const Text('Sign Up'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
