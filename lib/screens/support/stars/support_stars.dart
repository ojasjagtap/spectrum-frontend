import 'package:autbuddy/constants.dart';
import 'package:autbuddy/screens/support/stars/support_edit_star.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportStars extends StatefulWidget {
  const SupportStars({super.key});

  @override
  State<SupportStars> createState() => _SupportStarsState();
}

class _SupportStarsState extends State<SupportStars> {
  List<Map<String, dynamic>> activeStars = [];
  List<Map<String, dynamic>> archivedStars = [];
  bool isLoading = true;
  int totalStars = 0;

  @override
  void initState() {
    super.initState();
    fetchStars();
    fetchTotalStars();
  }

  Future<void> fetchTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    final String? childEmail = prefs.getString('currentChildEmail');

    if (childEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/get-user-stars";

    try {
      final response = await http.get(
        Uri.parse("$url?email=$childEmail"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          totalStars = data['stars'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch stars.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while fetching stars.")),
      );
    }
  }

  Future<void> fetchStars() async {
    final prefs = await SharedPreferences.getInstance();
    final String? supportEmail = prefs.getString('email');
    final String? childEmail = prefs.getString('currentChildEmail');

    if (supportEmail == null || childEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Child or support email is missing!")),
      );
      return;
    }

    const String url = "$baseUrl/get-stars";

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
        final data = jsonDecode(response.body);

        setState(() {
          activeStars = List<Map<String, dynamic>>.from(data['activeStars']);
          archivedStars =
              List<Map<String, dynamic>>.from(data['archivedStars']);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch stars")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching stars")),
      );
    }
  }

  Future<void> updateStarStatus(String starId, String newStatus) async {
    const String url = "$baseUrl/update-star-status";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"starId": starId, "status": newStatus}),
      );

      if (response.statusCode == 200) {
        fetchStars();
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while updating star")),
      );
    }
  }

  Future<void> deleteStar(String starId) async {
    const String url = "$baseUrl/delete-star";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Star"),
          content: const Text("Are you sure you want to delete this star?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.delete(
                    Uri.parse(url),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode({"starId": starId}),
                  );

                  if (response.statusCode == 200) {
                    fetchStars();
                  } else {
                    final errorMessage = jsonDecode(response.body)['message'];
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("An error occurred while deleting star")),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
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
                  Navigator.pushReplacementNamed(context, '/support_children');
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
              "STARS",
              style: TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  Text(
                    "$totalStars",
                    style: const TextStyle(
                      color: Color(0xff666666),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : activeStars.isEmpty && archivedStars.isEmpty
                    ? const Center(
                        child: Text(
                          "No stars added yet.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
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
                              if (activeStars.isNotEmpty) ...[
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ACTIVE",
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
                                  itemCount: activeStars.length,
                                  itemBuilder: (context, index) {
                                    final star = activeStars[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SupportEditStar(
                                                    starId: star["_id"],
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            star["name"],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff666666),
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.archive,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    updateStarStatus(
                                                        star["_id"],
                                                        "completed"),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    deleteStar(star["_id"]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (archivedStars.isNotEmpty) ...[
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "ARCHIVE",
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
                                  itemCount: archivedStars.length,
                                  itemBuilder: (context, index) {
                                    final star = archivedStars[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SupportEditStar(
                                                    starId: star["_id"],
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            star["name"],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff666666),
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.unarchive,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    updateStarStatus(
                                                        star["_id"], "pending"),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    deleteStar(star["_id"]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
          ),
          SizedBox(
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
                Navigator.pushNamed(context, '/support_add_star');
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
          Container(
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
                        border: Border.all(
                          color: const Color(0xff69a2ed),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
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
                        color: const Color(0xfff8bc58).withOpacity(0.2),
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
                          Navigator.pushReplacementNamed(
                              context, "/support_data");
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
        ],
      ),
    );
  }
}
