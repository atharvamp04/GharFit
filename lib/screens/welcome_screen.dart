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
  bool showForm = false;

  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController(); // For sign up

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
          MaterialPageRoute(builder: (_) =>  HomePage()),
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
          showForm = true;
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
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/welcome/home_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Logo and App Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.home, color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text('Nhome', style: TextStyle(color: Colors.white, fontSize: 22)),
                  ],
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
              // Bottom White Container
              Container(
                width: double.infinity,
                height: 470,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Toggle Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        toggleButton('Login', isLogin),
                        const SizedBox(width: 10),
                        toggleButton('Sign Up', !isLogin),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Form Area
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
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
                      ),
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
        ],
      ),
    );
  }

  Widget toggleButton(String text, bool selected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isLogin = (text == 'Login');
          showForm = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? Colors.black : Colors.white,
        foregroundColor: selected ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text),
    );
  }

  Widget socialButton(String text, String iconPath) {
    return OutlinedButton.icon(
      onPressed: () {},
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
        TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 10),
        TextField(obscureText: true, controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onLogin, child: const Text('Login')),
      ],
    );
  }
}

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
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
        const SizedBox(height: 10),
        TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
        const SizedBox(height: 10),
        TextField(obscureText: true, controller: passwordController, decoration: const InputDecoration(labelText: 'Password')),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onSignup, child: const Text('Sign Up')),
      ],
    );
  }
}

