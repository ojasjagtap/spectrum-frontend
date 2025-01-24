import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportAddSupport extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  SupportAddSupport({Key? key}) : super(key: key);

  Future<void> linkSupport(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? currentSupportEmail = prefs.getString('email');

    if (currentSupportEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current user email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/link-support";

    if (emailController.text.isEmpty || nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all fields!")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "currentSupportEmail": currentSupportEmail,
          "newSupportEmail": emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Support linked successfully!")),
        // );
        Navigator.pushReplacementNamed(context, "/support_messages");
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 80,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/support_messages");
                },
                child: const Text(
                  "Back",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Text(
              "Add",
              style: TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 80),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextField(
              controller: nameController,
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Email Field
            TextField(
              controller: emailController,
              style: const TextStyle(
                color: Color(0xff666666),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () => linkSupport(context),
                child: const Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffe8e8e8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffcf6b6e).withOpacity(0.2),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/support_tasks");
                    },
                    icon: const Icon(Icons.list_alt, color: Color(0xffcf6b6e)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Tasks",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffcf6b6e)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xff69a2ed).withOpacity(0.2),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/support_stars");
                    },
                    icon:
                        const Icon(Icons.star_border, color: Color(0xff69a2ed)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Stars",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff69a2ed)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xfff8bc58),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, "/support_messages");
                    },
                    icon: const Icon(Icons.message_outlined,
                        color: Color(0xfff8bc58)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Messages",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xfff8bc58)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.2),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/support_data");
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.green),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Mood",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
