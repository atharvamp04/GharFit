import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLogin = true;
  bool showForm = true;

  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  void loginUser() async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  void signupUser() async {
    try {
      final res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful. Please verify your email.')),
        );
        setState(() {
          isLogin = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background Image
              SizedBox.expand(
                child: Image.asset(
                  'assets/welcome/home_background.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              SafeArea(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: constraints.maxHeight,
                  child: SingleChildScrollView(
                    physics: isKeyboardVisible
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            // Logo
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  'assets/logo/logo.png',
                                  height: 36,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Headline
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Discover Your\nDream Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // White Form Container
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buildAnimatedToggleButton('Login', isLogin),
                                      const SizedBox(width: 10),
                                      buildAnimatedToggleButton('Sign Up', !isLogin),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (child, animation) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0.0, 0.3),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: FadeTransition(opacity: animation, child: child),
                                      );
                                    },
                                    child: showForm
                                        ? isLogin
                                        ? LoginFormWidget(
                                      key: const ValueKey('login'),
                                      emailController: emailController,
                                      passwordController: passwordController,
                                      onLogin: loginUser,
                                    )
                                        : SignupFormWidget(
                                      key: const ValueKey('signup'),
                                      nameController: nameController,
                                      emailController: emailController,
                                      passwordController: passwordController,
                                      onSignup: signupUser,
                                    )
                                        : const SizedBox.shrink(),
                                  ),

                                  const SizedBox(height: 16),
                                  const Text("or Login with", style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 16),
                                  socialButton('Continue with Google', 'assets/welcome/Google.png'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }




  Widget buildAnimatedToggleButton(String text, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.red),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            isLogin = (text == 'Login');
            showForm = true;
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget socialButton(String text, String iconPath) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Add Google login logic
      },
      icon: Image.asset(iconPath, height: 24),
      label: Text(text, style: const TextStyle(fontSize: 16)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}

// Login Form Widget
class LoginFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        customTextField(emailController, 'Email', false),
        const SizedBox(height: 12),
        customTextField(passwordController, 'Password', true),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Login', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

// Signup Form Widget
class SignupFormWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignup;

  const SignupFormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        customTextField(nameController, 'Full Name', false),
        const SizedBox(height: 12),
        customTextField(emailController, 'Email', false),
        const SizedBox(height: 12),
        customTextField(passwordController, 'Password', true),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Sign Up', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

// Custom Text Field (outside any class)
Widget customTextField(TextEditingController controller, String label, bool isPassword) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

