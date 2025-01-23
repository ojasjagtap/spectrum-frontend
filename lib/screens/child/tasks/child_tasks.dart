import 'package:autbuddy/constants.dart';
import 'package:autbuddy/screens/child/tasks/child_task_details.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChildTasks extends StatefulWidget {
  const ChildTasks({super.key});

  @override
  State<ChildTasks> createState() => _ChildTasksState();
}

class _ChildTasksState extends State<ChildTasks> {
  Map<String, List<Map<String, dynamic>>> supports = {};
  Map<String, List<Map<String, dynamic>>> filteredSupports = {};
  int stars = 0;
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchStars();
  }

  Future<void> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/get-child-tasks";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> taskList = data['tasks'];

        setState(() {
          supports = {
            for (var support in taskList)
              support['_id']: List<Map<String, dynamic>>.from(support['tasks'])
          };
          filteredSupports = Map.from(supports);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch tasks.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while fetching tasks.")),
      );
    }
  }

  Future<void> fetchStars() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email');

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User email not found!")),
      );
      return;
    }

    const String url = "$baseUrl/get-user-stars";

    try {
      final response = await http.get(
        Uri.parse("$url?email=$email"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          stars = data['stars'];
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

  void filterTasks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSupports = Map.from(supports);
      } else {
        filteredSupports = supports.map((key, tasks) {
          final filteredTasks = tasks
              .where((task) => task['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
          return MapEntry(key, filteredTasks);
        })
          ..removeWhere((key, tasks) => tasks.isEmpty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    stars.toString(),
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xfff6f6f6),
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffe8e8e8)),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffe8e8e8)),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  onChanged: filterTasks,
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : supports.isEmpty
                        ? const Center(
                            child: Text(
                              "No tasks available.",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.only(bottom: 120, left: 16),
                            itemCount: filteredSupports.keys.length,
                            itemBuilder: (context, index) {
                              final support =
                                  filteredSupports.keys.elementAt(index);
                              final tasks = filteredSupports[support]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      support,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: tasks.length,
                                      itemBuilder: (context, taskIndex) {
                                        final task = tasks[taskIndex];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChildTaskDetails(
                                                        taskId: task["_id"]),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              children: [
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xfff6f6f6),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        border: Border.all(
                                                            color: const Color(
                                                                0xffe8e8e8)),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              task['image']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 4,
                                                      right: 4,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "${task['starsWorth']}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xff666666),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.orange,
                                                              size: 16,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  task['name'],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ],
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
          ),
        ],
      ),
    );
  }
}
