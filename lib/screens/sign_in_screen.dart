import 'package:ecommerce_app/screens/forgot_password_screen.dart';
import 'package:ecommerce_app/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/build_text_button.dart';
import 'home_screen.dart';
import '../widgets/filled_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  static const color1 = Color(0xff4c505b);
  static const color2 = Color(0xff2596be);
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    authProvider.loadRememberedCredentials(emailController, passwordController);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/signIn.png',
                  fit: BoxFit.cover,
                  ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap:  () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const Spacer(flex: 1),
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(flex: 1),
                          FilledTextField(
                            controller: emailController,
                            labelText: 'Enter your email address',
                            obscureText: false,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Email';
                              } else if (!value.contains('@')) {
                                return 'Please enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          FilledTextField(
                            controller: passwordController,
                            labelText: 'Enter your password',
                            obscureText: !_isPasswordVisible,
                            onVisibilityToggle: _togglePasswordVisibility,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                          ),
                          const Spacer(flex: 3),Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: authProvider.rememberMe,
                                onChanged: (value) =>
                                    authProvider.toggleRememberMe(value!),
                                activeColor: color1,
                              ),
                              const Text("Remember Me")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: color1,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (authProvider.isLoading)
                                const CircularProgressIndicator()
                              else
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: color1,
                                  child: IconButton(
                                    color: Colors.white,
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        final errorMessage =
                                        await authProvider.signIn(
                                            emailController.text,
                                            passwordController.text);

                                        if (errorMessage == null) {
                                          if (!context.mounted) return;
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const HomeScreen(),
                                            ),
                                          );
                                        } else {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(errorMessage),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 30,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BuildTextButton(
                                text: 'Sign Up',
                                color: color2,
                                widget: SignupScreen(),
                              ),
                              BuildTextButton(
                                text: 'Forgot Password?',
                                color: color2,
                                widget: ForgotPasswordScreen(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
