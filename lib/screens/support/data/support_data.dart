import 'dart:convert';
import 'package:autbuddy/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, String> emotionImages = {
  'happy': 'assets/happy.png',
  'sad': 'assets/sad.png',
  'angry': 'assets/angry.png',
};

class SupportData extends StatefulWidget {
  const SupportData({super.key});

  @override
  _SupportDataState createState() => _SupportDataState();
}

class _SupportDataState extends State<SupportData> {
  List<Map<String, dynamic>> moodData = [];
  String latestMood = "happy";
  String latestMoodTimestamp = "${DateTime.now()}";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMoodData();
  }

  Future<void> fetchMoodData({int days = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentChildEmail');

    if (email == null) {
      print("Child email not found in SharedPreferences.");
      return;
    }

    const String url = "$baseUrl/get-mood-trend";

    try {
      final response = await http.get(
        Uri.parse("$url?email=$email&days=$days"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'].isNotEmpty) {
          setState(() {
            moodData = data['data'].map<Map<String, dynamic>>((mood) {
              return {
                'mood': mood['mood'] == "happy"
                    ? 5
                    : mood['mood'] == "sad"
                        ? 3
                        : 1,
                'timestamp': mood['timestamp'],
              };
            }).toList();
            latestMood = data['data'].last['mood'];
            latestMoodTimestamp = data['data'].last['timestamp'];
            isLoading = false;
          });
        } else {
          print(data['message']);
          setState(() {
            moodData = [];
            isLoading = false;
          });
        }
      } else {
        print(
            "Failed to fetch mood trend data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while fetching mood trend data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueDates = moodData
        .map((entry) {
          final date = DateTime.parse(entry['timestamp']);
          return '${date.month}/${date.day}';
        })
        .toSet()
        .toList();

    final Map<String, Map<int, int>> groupedData = {};
    for (final entry in moodData) {
      final date = DateTime.parse(entry['timestamp']);
      final formattedDate = '${date.month}/${date.day}';
      final mood = entry['mood'];
      groupedData.putIfAbsent(formattedDate, () => {});
      groupedData[formattedDate]!
          .update(mood, (count) => count + 1, ifAbsent: () => 1);
    }

    final scatterSpots = <ScatterSpot>[];
    for (var i = 0; i < uniqueDates.length; i++) {
      final date = uniqueDates[i];
      final moodCounts = groupedData[date]!;
      int index = 0;
      moodCounts.forEach((mood, count) {
        double jitter = (index % 2 == 0 ? 0.02 : -0.02) * count;
        scatterSpots.add(
          ScatterSpot(
            (i.toDouble() + jitter).clamp(0, uniqueDates.length.toDouble() - 1),
            mood.toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: 4 + count.clamp(1, 5).toDouble() * 1.2,
              color: Colors.green,
            ),
          ),
        );
        index++;
      });
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
              "MOOD",
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 48.0, bottom: 16, right: 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Latest Mood Section
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                emotionImages[latestMood] ?? 'assets/happy.png',
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                latestMood[0].toUpperCase() +
                                    latestMood.substring(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff666666),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '(as of $latestMoodTimestamp)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 24.0, bottom: 16.0, left: 16, right: 24),
                            child: SizedBox(
                              height: 300,
                              child: ScatterChart(
                                ScatterChartData(
                                  scatterSpots: scatterSpots,
                                  minX: 0,
                                  maxX: uniqueDates.length.toDouble() - 1,
                                  minY: 0,
                                  maxY: 6,
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: true,
                                    getDrawingHorizontalLine: (value) =>
                                        const FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 0.5,
                                    ),
                                    getDrawingVerticalLine: (value) =>
                                        const FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 0.5,
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 55,
                                        getTitlesWidget: (value, meta) {
                                          if (value == 1) {
                                            return const Text('Angry');
                                          }
                                          if (value == 3) {
                                            return const Text('Sad');
                                          }
                                          if (value == 5) {
                                            return const Text('Happy');
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 20,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= uniqueDates.length) {
                                            return const Text('');
                                          }
                                          return Text(uniqueDates[index]);
                                        },
                                        interval: 1,
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  scatterTouchData: ScatterTouchData(
                                    enabled: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
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
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
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
                ),
              ],
            ),
    );
  }
}
