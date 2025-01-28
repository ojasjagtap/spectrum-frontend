import 'dart:async';
import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('authToken');

    if (token != null) {
      final String? userType = prefs.getString('userType');
      final String? email = prefs.getString('email');

      if (email != null) {
        if (userType == "Support") {
          Navigator.pushReplacementNamed(context, "/support_children");
        } else {
          Navigator.pushReplacementNamed(context, "/child_home");
        }
      }
    }
  }

  Future<void> _checkServerConnection() async {
    const String serverUrl = "$baseUrl/";
    try {
      final response = await http.get(Uri.parse(serverUrl));
      if (response.statusCode == 200) {
        checkLoginStatus();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        print("Server connection failed. Status code: ${response.statusCode}");
        _retryConnection();
      }
    } catch (e) {
      print("Error connecting to server: $e");
      _retryConnection();
    }
  }

  void _retryConnection() {
    Future.delayed(const Duration(seconds: 2), _checkServerConnection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
              width: 250,
            ),
            const Text(
              "SPECTRUM",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
