import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupportEditTask extends StatefulWidget {
  final String taskId;

  const SupportEditTask({Key? key, required this.taskId}) : super(key: key);

  @override
  _SupportEditTaskState createState() => _SupportEditTaskState();
}

class _SupportEditTaskState extends State<SupportEditTask> {
  late TextEditingController nameController;
  late List<String> steps;
  late int starCount;
  final TextEditingController stepController = TextEditingController();
  bool isLoading = true;
  String taskImage = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    steps = [];
    starCount = 0;
    _fetchTaskDetails();
  }

  Future<void> _fetchTaskDetails() async {
    const String url = "$baseUrl/get-task-details";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"taskId": widget.taskId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nameController.text = data["name"];
          steps = List<String>.from(data["steps"]);
          starCount = data["starsWorth"];
          taskImage = data["image"];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch task details")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }
  }

  Future<void> _updateTask() async {
    const String url = "$baseUrl/update-task";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "taskId": widget.taskId,
          "name": nameController.text.trim(),
          "steps": steps,
          "starsWorth": starCount,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, "/support_tasks");
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }
  }

  void _addStep(String step) {
    setState(() {
      steps.add(step);
    });
  }

  void _deleteStep(int index) {
    setState(() {
      steps.removeAt(index);
    });
  }

  void _showAddStepDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Step"),
          content: TextField(
            controller: stepController,
            decoration:
                const InputDecoration(hintText: "Enter step description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (stepController.text.isNotEmpty) {
                  _addStep(stepController.text);
                  stepController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    stepController.dispose();
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
                  Navigator.pushReplacementNamed(context, "/support_tasks");
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
          : Stack(
              children: [
                SingleChildScrollView(
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
                            border: Border.all(color: const Color(0xffe8e8e8)),
                            image: DecorationImage(
                              image: NetworkImage(taskImage),
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
                          color: Color(0xff666666),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Task name",
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
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/clipboard.png',
                              width: screenWidth - 48,
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 130),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 60.0),
                              child: ReorderableListView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = steps.removeAt(oldIndex);
                                    steps.insert(newIndex, item);
                                  });
                                },
                                children: [
                                  for (int index = 0;
                                      index < steps.length;
                                      index++)
                                    Card(
                                      key: ValueKey(steps[index]),
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                            color: Color(0xffe8e8e8)),
                                      ),
                                      child: ListTile(
                                        title: Text(steps[index]),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.grey),
                                          onPressed: () => _deleteStep(index),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        elevation: 0.0,
                        onPressed: _showAddStepDialog,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
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
                            if (nameController.text.isNotEmpty &&
                                starCount != 0) {
                              _updateTask();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter task name and star count!"),
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
                                    border: Border.all(
                                      color: const Color(0xffcf6b6e),
                                      width: 2,
                                    ),
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
                                    color: const Color(0xfff8bc58)
                                        .withOpacity(0.2),
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
