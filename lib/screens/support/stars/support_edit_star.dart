import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupportEditStar extends StatefulWidget {
  final String starId;

  const SupportEditStar({Key? key, required this.starId}) : super(key: key);

  @override
  _SupportEditStarState createState() => _SupportEditStarState();
}

class _SupportEditStarState extends State<SupportEditStar> {
  late TextEditingController nameController;
  late int starCount;
  String status = "";
  bool isLoading = true;
  String starImage = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    _fetchStarDetails();
  }

  Future<void> _fetchStarDetails() async {
    const String url = "$baseUrl/get-star-details";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"starId": widget.starId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          nameController.text = data["name"];
          starCount = data["value"];
          status = data["status"];
          starImage = data["image"];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch star details")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while fetching star details")),
      );
    }
  }

  Future<void> _updateStar() async {
    const String url = "$baseUrl/update-star";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "starId": widget.starId,
          "name": nameController.text.trim(),
          "value": starCount,
          "status": status,
        }),
      );

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Star updated successfully!")),
        // );
        Navigator.pushReplacementNamed(context, "/support_stars");
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while updating the star")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
                  Navigator.pushReplacementNamed(context, "/support_stars");
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
              "Edit",
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
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // Handle photo upload
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xfff6f6f6),
                              borderRadius: BorderRadius.circular(12.0),
                              border:
                                  Border.all(color: const Color(0xffe8e8e8)),
                              image: DecorationImage(
                                image: NetworkImage(starImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff666666),
                          ),
                          decoration: const InputDecoration(
                            hintText: "Star name",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$starCount\t",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: (starCount == 0)
                                    ? Colors.grey
                                    : const Color(0xff666666),
                              ),
                            ),
                            const Icon(Icons.star, color: Colors.orange),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (starCount > 0) starCount -= 5;
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.grey),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  starCount += 5;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        if (nameController.text.isNotEmpty && starCount != 0) {
                          _updateStar();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please enter star name and count!"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
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
