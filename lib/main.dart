import 'package:autbuddy/screens/child/home/child_home.dart';
import 'package:autbuddy/screens/login.dart';
import 'package:autbuddy/screens/signup.dart';
import 'package:autbuddy/screens/child/messages/child_messages.dart';
import 'package:autbuddy/screens/child/stars/child_stars.dart';
import 'package:autbuddy/screens/child/tasks/child_tasks.dart';
import 'package:autbuddy/screens/splash.dart';
import 'package:autbuddy/screens/support/children/support_children.dart';
import 'package:autbuddy/screens/support/data/support_data.dart';
import 'package:autbuddy/screens/support/children/support_add_child.dart';
import 'package:autbuddy/screens/support/messages/support_add_support.dart';
import 'package:autbuddy/screens/support/messages/support_messages.dart';
import 'package:autbuddy/screens/support/stars/support_add_star.dart';
import 'package:autbuddy/screens/support/stars/support_stars.dart';
import 'package:autbuddy/screens/support/tasks/support_add_task.dart';
import 'package:autbuddy/screens/support/tasks/support_tasks.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02A959)),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/support_children': (context) => const SupportChildren(),
        '/support_add_child': (context) => const SupportAddChild(),
        '/support_tasks': (context) => const SupportTasks(),
        '/support_add_task': (context) => const SupportAddTask(),
        '/support_stars': (context) => const SupportStars(),
        '/support_add_star': (context) => const SupportAddStar(),
        '/support_messages': (context) => const SupportMessages(),
        '/support_add_support': (context) => SupportAddSupport(),
        '/support_data': (context) => const SupportData(),
        '/child_home': (context) => const ChildHome(),
        '/child_tasks': (context) => const ChildTasks(),
        '/child_stars': (context) => const ChildStars(),
        '/child_messages': (context) => const ChildMessages(),
      },
    );
  }
}
