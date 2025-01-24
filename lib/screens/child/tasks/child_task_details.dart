import 'package:autbuddy/constants.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChildTaskDetails extends StatefulWidget {
  final String taskId;

  const ChildTaskDetails({Key? key, required this.taskId}) : super(key: key);

  @override
  _ChildTaskDetailsState createState() => _ChildTaskDetailsState();
}

class _ChildTaskDetailsState extends State<ChildTaskDetails> {
  String taskImage = "";
  String taskName = "";
  int starCount = 0;
  List<String> steps = [];
  List<bool> stepCompletion = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
          taskImage = data['image'];
          taskName = data['name'];
          starCount = data['starsWorth'];
          steps = List<String>.from(data['steps']);
          stepCompletion = List<bool>.filled(steps.length, false);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch task details.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching data.")),
      );
    }
  }

  Future<void> updateTaskStatus() async {
    const String url = "$baseUrl/update-task-status";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"taskId": widget.taskId, "status": "completed"}),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, "/child_tasks");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update task status.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while updating task.")),
      );
    }
  }

  void _checkCompletion() {
    if (stepCompletion.every((isChecked) => isChecked)) {
      updateTaskStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all steps first.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  Navigator.pushReplacementNamed(context, "/child_tasks");
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
              "Steps",
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
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
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
                const SizedBox(height: 8),
                Text(
                  taskName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff666666),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$starCount\t",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff666666),
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.orange),
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
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: Column(
                          children: [
                            for (int index = 0; index < steps.length; index++)
                              Card(
                                key: ValueKey(steps[index]),
                                color: Colors.white,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: const BorderSide(
                                      color: Color(0xffe8e8e8)),
                                ),
                                child: ListTile(
                                  title: Text(steps[index]),
                                  trailing: Checkbox(
                                    value: stepCompletion[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        stepCompletion[index] = value ?? false;
                                      });
                                    },
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _checkCompletion,
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
                              border: Border.all(
                                color: const Color(0xffcf6b6e),
                                width: 2,
                              ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
