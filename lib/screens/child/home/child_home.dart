import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, String> emotionImages = {
  'happy': 'assets/happy.png',
  'sad': 'assets/sad.png',
  'angry': 'assets/angry.png',
};

String _selectedEmotion = 'happy';

class MoodDrawer extends StatefulWidget {
  final VoidCallback onDone;

  const MoodDrawer({Key? key, required this.onDone}) : super(key: key);

  @override
  State<MoodDrawer> createState() => _MoodDrawerState();
}

class _MoodDrawerState extends State<MoodDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _hideDrawer() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found!")),
      );
      return;
    }

    const url = "$baseUrl/add-mood";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "mood": _selectedEmotion,
        }),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update mood.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error occurred while updating mood.")),
      );
    }

    _animationController.reverse().then((_) => widget.onDone());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            Opacity(
              opacity: _animationController.value * 0.6,
              child: GestureDetector(
                onTap: _hideDrawer,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
            // Mood Drawer
            Transform.translate(
              offset: Offset(
                  0,
                  MediaQuery.of(context).size.height *
                      (1 - _animationController.value)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "How do you feel?",
                        style: TextStyle(
                          color: Color(0xff666666),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      // Emotion Selection
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: emotionImages.keys.length,
                        itemBuilder: (context, index) {
                          String emotion = emotionImages.keys.elementAt(index);
                          String imagePath = emotionImages[emotion]!;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmotion = emotion;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: _selectedEmotion == emotion
                                    ? Border.all(color: Colors.green, width: 3)
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(imagePath),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
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
                          onPressed: _hideDrawer,
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChildHome extends StatefulWidget {
  const ChildHome({Key? key}) : super(key: key);

  @override
  State<ChildHome> createState() => _ChildHomeState();
}

class _ChildHomeState extends State<ChildHome> {
  bool _isMoodDrawerVisible = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');

      if (email == null) {
        setState(() {
          _userName = "User";
        });
        return;
      }

      const url = "$baseUrl/get-user-name";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['name'] ?? "User";
        });
      } else {
        setState(() {
          _userName = "User";
        });
      }
    } catch (e) {
      setState(() {
        _userName = "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        16 * 2;
    const navBarHeight = 180;
    final cardHeight = (availableHeight - navBarHeight - 16 * 4) / 3;

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
              "Home",
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildCard(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/child_tasks");
                      },
                      color: const Color(0xffcf6b6e),
                      label: "TASKS",
                      imagePath: 'assets/boy2.png',
                      cardHeight: cardHeight,
                    ),
                    _buildCard(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/child_stars");
                      },
                      color: const Color(0xff69a2ed),
                      label: "STARS",
                      imagePath: 'assets/girl1.png',
                      cardHeight: cardHeight,
                    ),
                    _buildCard(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, "/child_messages");
                      },
                      color: const Color(0xfff8bc58),
                      label: "MESSAGES",
                      imagePath: 'assets/boy3.png',
                      cardHeight: cardHeight,
                    ),
                  ],
                ),
              ),
              // Bottom Navigation Bar
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
                child: Column(
                  children: [
                    Text(
                      "Hello ${_userName ?? 'User'}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
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
                            const SizedBox(height: 4.0),
                            const Text(
                              "Tasks",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffcf6b6e),
                              ),
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
                                icon: const Icon(Icons.star_outline,
                                    color: Color(0xff69a2ed)),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Stars",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff69a2ed),
                              ),
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
                                      context, "/child_messages");
                                },
                                icon: const Icon(Icons.message_outlined,
                                    color: Color(0xfff8bc58)),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Messages",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xfff8bc58),
                              ),
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
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.home_outlined,
                                    color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            const Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Mood Drawer
          if (_isMoodDrawerVisible)
            MoodDrawer(
              onDone: () {
                setState(() {
                  _isMoodDrawerVisible = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required VoidCallback onTap,
    required Color color,
    required String label,
    required String imagePath,
    required double cardHeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Card(
              elevation: 2,
              color: color,
              child: Container(
                height: cardHeight,
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Positioned(
          //   // top: -100, // Position the image 100 pixels above the card
          //   left: label == "MESSAGES" ? 20 : null,
          //   right: label == "STARS" ? 20 : null,
          //   child: Image.asset(
          //     imagePath,
          //     width: 200,
          //     height: 200,
          //   ),
          // ),
        ],
      ),
    );
  }
}
