import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportMessage extends StatefulWidget {
  final String otherUserEmail;
  final String otherUserName;

  const SupportMessage(
      {super.key, required this.otherUserEmail, required this.otherUserName});

  @override
  State<SupportMessage> createState() => _SupportMessageState();
}

class _SupportMessageState extends State<SupportMessage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserEmail = prefs.getString('email');

    if (currentUserEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current user email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/get-messages";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "currentUserEmail": currentUserEmail,
          "otherUserEmail": widget.otherUserEmail,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(data['messages']);
          isLoading = false;
        });

        // Auto-scroll to the latest message
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch messages")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching data")),
      );
    }
  }

  Future<void> sendMessage() async {
    if (_controller.text.isNotEmpty) {
      if (currentUserEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Current user email not found!")),
        );
        return;
      }

      const String url = "$baseUrl/send-message";

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "sender": currentUserEmail,
            "receiver": widget.otherUserEmail,
            "message": _controller.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            messages.add({
              "sender": currentUserEmail,
              "message": _controller.text.trim(),
            });
          });
          _controller.clear();

          // Auto-scroll to the latest message
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to send message")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while sending data")),
        );
      }
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
                  Navigator.pop(context);
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
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 80),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isCurrentUser =
                                  message["sender"] == currentUserEmail;
                              return Align(
                                alignment: isCurrentUser
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Colors.green
                                        : const Color(0xfff6f6f6),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    message["message"]!,
                                    style: TextStyle(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 64),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xfff6f6f6),
                hintText: "Message here...",
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffe8e8e8)),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffe8e8e8)),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.green),
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
                        color: const Color(0xff69a2ed).withOpacity(0.2),
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
