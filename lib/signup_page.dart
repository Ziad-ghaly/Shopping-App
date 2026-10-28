import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'test.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() {
    return _SignupPageState();
  }
}

class _SignupPageState extends State<SignupPage> {
  final _keyForm = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signUp() {
    if (_keyForm.currentState!.validate()) {
      Database.username = _usernameController.text;
      Database.password = _passwordController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created, please login")),
      );
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    print(" start Signup");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    print(" finish Signup");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _keyForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return "Username must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains("@") ||
                        !value.contains(".")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Confirm Password"),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Back to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
