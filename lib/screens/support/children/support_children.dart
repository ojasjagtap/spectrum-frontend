import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportChildren extends StatefulWidget {
  const SupportChildren({Key? key}) : super(key: key);

  @override
  State<SupportChildren> createState() => _SupportChildrenState();
}

class _SupportChildrenState extends State<SupportChildren> {
  List<Map<String, dynamic>> children = [];
  bool isLoading = true;
  late String supportEmail;

  @override
  void initState() {
    super.initState();
    fetchSupportEmail();
  }

  Future<void> fetchSupportEmail() async {
    final prefs = await SharedPreferences.getInstance();
    supportEmail = prefs.getString('email') ?? '';

    if (supportEmail.isNotEmpty) {
      fetchChildren();
    }
  }

  Future<void> fetchChildren() async {
    const String url = "$baseUrl/get-linked-children";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"supportEmail": supportEmail}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          children = List<Map<String, dynamic>>.from(responseData['children']);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load children");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching children")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteChild(String childEmail) async {
    const String url = "$baseUrl/remove-child-link";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Child"),
        content: const Text("Are you sure you want to delete this child?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await http.post(
                  Uri.parse(url),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "supportEmail": supportEmail,
                    "childEmail": childEmail,
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    children
                        .removeWhere((child) => child["email"] == childEmail);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Child link removed successfully")),
                  );
                } else {
                  final errorMessage = jsonDecode(response.body)['message'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error removing child link")),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Text(
              "CHILDREN",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : children.isEmpty
              ? const Center(
                  child: Text(
                    "No children added yet.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xfff6f6f6),
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffe8e8e8)),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffe8e8e8)),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: children.length,
                          itemBuilder: (context, index) {
                            final child = children[index];
                            return GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                await prefs.setString(
                                    'currentChildEmail', child["email"]);

                                Navigator.pushReplacementNamed(
                                    context, "/support_tasks");
                              },
                              child: Card(
                                elevation: 0,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Color(0xffe8e8e8),
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ListTile(
                                  title: Text(
                                    child["name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Icon(
                                      //   child["hasNotifications"]
                                      //       ? Icons.notifications_active
                                      //       : Icons.notifications_none,
                                      //   color: child["hasNotifications"]
                                      //       ? Colors.orange
                                      //       : Colors.grey,
                                      // ),
                                      // const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            deleteChild(child["email"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: double.infinity,
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
                                  context, '/support_add_child');
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
                      const SizedBox(height: 16)
                    ],
                  ),
                ),
    );
  }
}
