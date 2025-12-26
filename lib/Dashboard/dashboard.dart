import 'package:bharvix_tv/home.dart';
import 'package:flutter/material.dart';

enum ButtomMenuItem { home, search, live, movies }

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ButtomMenuItem _selected = ButtomMenuItem.home;

  int get _currentIndex => ButtomMenuItem.values.indexOf(_selected);

  void _onItemTapped(int index) {
    setState(() {
      _selected = ButtomMenuItem.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainContent(selected: _selected),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF261C1C),
        selectedItemColor: const Color(0xFFEA2A33),
        unselectedItemColor: const Color(0xFFB89D9F),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  final ButtomMenuItem selected;

  const MainContent({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    switch (selected) {
      case ButtomMenuItem.home:
        return const HomeScreen();

      case ButtomMenuItem.search:
        return const Center();

      case ButtomMenuItem.live:
        return const Center();

      case ButtomMenuItem.movies:
        return const Center(
          child: Text(
            'Movies Section Coming Soon!',
            style: TextStyle(fontSize: 24.0),
          ),
        );
    }
  }
}
