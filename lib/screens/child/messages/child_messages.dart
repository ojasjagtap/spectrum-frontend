import 'package:autbuddy/constants.dart';
import 'package:autbuddy/screens/child/messages/child_message.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChildMessages extends StatefulWidget {
  const ChildMessages({super.key});

  @override
  State<ChildMessages> createState() => _ChildMessagesState();
}

class _ChildMessagesState extends State<ChildMessages> {
  List<Map<String, dynamic>> supports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSupports();
  }

  Future<void> fetchSupports() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/get-linked-supports";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          supports = List<Map<String, dynamic>>.from(
              data['supports'].map((support) => {
                    "name": support['name'],
                    "email": support['email'],
                  }));
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch supports.")),
        );
      }
    } catch (e) {
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Navigator.pushReplacementNamed(context, "/child_home");
                },
                child: const Text(
                  "Home",
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
            const SizedBox(
              width: 80,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
                          // Support Section
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
                                        builder: (context) => ChildMessage(
                                              otherUserEmail: support["email"],
                                              otherUserName: support["name"],
                                            )),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
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
                                    // trailing: Row(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: [
                                    //     Icon(
                                    //       supportNotifications[index]
                                    //           ? Icons.notifications_active
                                    //           : Icons.notifications_none,
                                    //       color: supportNotifications[index]
                                    //           ? Colors.orange
                                    //           : Colors.grey,
                                    //     ),
                                    //   ],
                                    // ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                            Navigator.pushReplacementNamed(
                                context, "/child_tasks");
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
                          color: const Color(0xff69a2ed).withOpacity(0.2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, "/child_stars");
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
                                context, "/child_home");
                          },
                          icon: const Icon(Icons.home_outlined,
                              color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Home",
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
    );
  }
}
