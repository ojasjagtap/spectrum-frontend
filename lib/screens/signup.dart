import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> signUp(
    String name, String email, String password, String userType) async {
  const String url = "$baseUrl/signup";

  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "userType": userType,
    }),
  );

  if (response.statusCode == 201) {
    print("User registered successfully");
  } else {
    print("Error: ${response.body}");
  }
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? selectedUserType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff666666),
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  filled: true,
                  fillColor: Color(0xfff6f6f6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Color(0xfff6f6f6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Color(0xfff6f6f6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  filled: true,
                  fillColor: Color(0xfff6f6f6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffe8e8e8)),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedUserType = "Support";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff6f6f6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Color(0xffe8e8e8)),
                        ),
                      ),
                      child: Text(
                        "Support",
                        style: TextStyle(
                          color: selectedUserType == "Support"
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedUserType = "Child";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff6f6f6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Color(0xffe8e8e8)),
                        ),
                      ),
                      child: Text(
                        "Child",
                        style: TextStyle(
                          color: selectedUserType == "Child"
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty &&
                      confirmPasswordController.text.isNotEmpty &&
                      selectedUserType != null) {
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      final name = nameController.text;
                      final email = emailController.text;
                      final password = passwordController.text;

                      await signUp(name, email, password, selectedUserType!);

                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Passwords do not match!")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter all user information!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14.0,
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
