import 'package:flutter/material.dart';

import 'exercise_library_screen.dart';
import 'plan_screen.dart';
import 'report_screen.dart';
import 'voice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const ExerciseLibraryScreen();
      case 1:
        return const PlanScreen();
      case 2:
        return const VoiceScreen();
      case 3:
        return const ReportScreen();
      default:
        return const ExerciseLibraryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: '动作库'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '计划'),
          BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: '语音'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: '报告'),
        ],
      ),
    );
  }
}
