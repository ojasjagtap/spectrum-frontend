import 'package:autbuddy/constants.dart';
import 'package:autbuddy/screens/support/tasks/support_edit_task.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SupportTasks extends StatefulWidget {
  const SupportTasks({super.key});

  @override
  State<SupportTasks> createState() => _SupportTasksState();
}

class _SupportTasksState extends State<SupportTasks> {
  List<Map<String, dynamic>> activeTasks = [];
  List<Map<String, dynamic>> archivedTasks = [];
  List<Map<String, dynamic>> filteredActiveTasks = [];
  List<Map<String, dynamic>> filteredArchivedTasks = [];
  bool isLoading = true;
  int totalStars = 0;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchStars();
  }

  Future<void> fetchStars() async {
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

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    const String url = "$baseUrl/update-task-status";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"taskId": taskId, "status": newStatus}),
      );

      if (response.statusCode == 200) {
        fetchTasks();
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while updating task")),
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    const String url = "$baseUrl/delete-task";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
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
                  body: jsonEncode({"taskId": taskId}),
                );

                if (response.statusCode == 200) {
                  fetchTasks();
                } else {
                  final errorMessage = jsonDecode(response.body)['message'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("An error occurred while deleting task")),
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

  Future<void> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? supportEmail = prefs.getString('email');
    final String? childEmail = prefs.getString('currentChildEmail');

    if (supportEmail == null || childEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Child or support information missing!")),
      );
      return;
    }

    const String url = "$baseUrl/get-tasks";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"supportEmail": supportEmail, "childEmail": childEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          activeTasks = List<Map<String, dynamic>>.from(data['activeTasks']);
          archivedTasks =
              List<Map<String, dynamic>>.from(data['archivedTasks']);
          filteredActiveTasks = List.from(activeTasks);
          filteredArchivedTasks = List.from(archivedTasks);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch tasks")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching tasks")),
      );
    }
  }

  void filterTasks(String query) {
    setState(() {
      filteredActiveTasks = activeTasks
          .where((task) => task['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      filteredArchivedTasks = archivedTasks
          .where((task) => task['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
                  Navigator.pushReplacementNamed(context, "/support_children");
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
              "TASKS",
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
                : activeTasks.isEmpty && archivedTasks.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks added yet.",
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
                                  filterTasks(value);
                                },
                              ),
                              if (filteredActiveTasks.isNotEmpty) ...[
                                const SizedBox(height: 16),
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
                                  itemCount: filteredActiveTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = filteredActiveTasks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SupportEditTask(
                                                    taskId: task["_id"],
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
                                            task["name"],
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
                                                    updateTaskStatus(
                                                        task["_id"],
                                                        "completed"),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    deleteTask(task["_id"]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              if (filteredArchivedTasks.isNotEmpty) ...[
                                const SizedBox(height: 16),
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
                                  itemCount: filteredArchivedTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = filteredArchivedTasks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SupportEditTask(
                                                    taskId: task["_id"],
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
                                            task["name"],
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
                                                    updateTaskStatus(
                                                        task["_id"], "pending"),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.grey),
                                                onPressed: () =>
                                                    deleteTask(task["_id"]),
                                              ),
                                            ],
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
                Navigator.pushNamed(context, '/support_add_task');
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
                        border: Border.all(
                          color: const Color(0xffcf6b6e),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
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
