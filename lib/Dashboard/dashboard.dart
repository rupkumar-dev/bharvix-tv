
import 'package:bharvix_tv/home.dart';
import 'package:bharvix_tv/screens/live_search.dart';
import 'package:flutter/material.dart';


// ---------------- MENU ----------------
enum BottomMenuItem { home, search, home2, movies }

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  BottomMenuItem _selected = BottomMenuItem.home;

  int get _currentIndex => BottomMenuItem.values.indexOf(_selected);

  void _onItemTapped(int index) {
    setState(() {
      _selected = BottomMenuItem.values[index];
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
   
        elevation: 0,
  
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  final BottomMenuItem selected;

  const MainContent({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    switch (selected) {
      case BottomMenuItem.home:
        return const HomeScreen2();

      case BottomMenuItem.search:
        return const SearchScreen();

      case BottomMenuItem.home2:
        return const Center(
          child: Text(
            'Explore',
            style: TextStyle(color: Colors.white),
          ),
        );

      case BottomMenuItem.movies:
        return const Center(
          child: Text(
            'Movies coming soon',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
        );
    }
  }
}
