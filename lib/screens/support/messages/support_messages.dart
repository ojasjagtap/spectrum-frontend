import 'package:autbuddy/constants.dart';
import 'package:autbuddy/screens/support/messages/support_message.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportMessages extends StatefulWidget {
  const SupportMessages({super.key});

  @override
  State<SupportMessages> createState() => _SupportMessagesState();
}

class _SupportMessagesState extends State<SupportMessages> {
  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> supports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLinkedUsers();
  }

  Future<void> fetchLinkedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? supportEmail = prefs.getString('email');

    if (supportEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Support email is missing!")),
      );
      return;
    }

    const String url = "$baseUrl/get-linked-users";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": supportEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          children = List<Map<String, dynamic>>.from(data['children']);
          supports = List<Map<String, dynamic>>.from(data['supports']);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch linked users")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, '/support_children');
                  },
                  child: const Text(
                    "Children",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Text(
                "MESSAGES",
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xfff6f6f6),
                              hintText: "Search",
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffe8e8e8)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xffe8e8e8)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            onChanged: (value) {
                              // Handle search logic
                            },
                          ),
                          const SizedBox(height: 16),
                          // Children Section
                          if (children.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "CHILDREN",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: children.length,
                              itemBuilder: (context, index) {
                                final child = children[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SupportMessage(
                                                otherUserEmail: child["email"],
                                                otherUserName: child["name"],
                                              )),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color(0xffe8e8e8)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        child["name"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff666666),
                                        ),
                                      ),
                                      // trailing: const Icon(
                                      //   Icons.notifications_none,
                                      //   color: Colors.grey,
                                      // ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Support Section
                          if (supports.isNotEmpty) ...[
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "SUPPORT",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: supports.length,
                              itemBuilder: (context, index) {
                                final support = supports[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SupportMessage(
                                                otherUserEmail:
                                                    support["email"],
                                                otherUserName: support["name"],
                                              )),
                                    );
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Color(0xffe8e8e8)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        support["name"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff666666),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Positioned(
                      bottom: 137.0,
                      left: 16.0,
                      right: 16.0,
                      child: SizedBox(
                        width: screenWidth - 32,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/support_add_support');
                          },
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
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
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
                                    color: const Color(0xffcf6b6e)
                                        .withOpacity(0.2),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/support_tasks");
                                    },
                                    icon: const Icon(Icons.list_alt,
                                        color: Color(0xffcf6b6e)),
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
                                    color: const Color(0xff69a2ed)
                                        .withOpacity(0.2),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/support_stars");
                                    },
                                    icon: const Icon(Icons.star_border,
                                        color: Color(0xff69a2ed)),
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
                                    onPressed: () {},
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
                                      Navigator.pushReplacementNamed(
                                          context, "/support_data");
                                    },
                                    icon: const Icon(
                                        Icons.emoji_emotions_outlined,
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
                    ),
                  ],
                ),
              ]));
  }
}
