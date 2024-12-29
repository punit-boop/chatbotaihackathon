import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_screen.dart';
import 'community_screen.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ChatScreen(),
    const CommunityScreen(),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Extends body behind the navigation bar
      body: _screens[_selectedIndex], // Switch between screens
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Space below the floating bar
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal margin for floating
          height: 70, // Height of the floating nav bar
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8), // Slight transparency for the nav bar
            borderRadius: BorderRadius.circular(30), // Rounded edges for the floating bar
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFFC8786D),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.transparent, // Transparent for floating effect
              showSelectedLabels: true,
              showUnselectedLabels: false,
              elevation: 0, // Remove default nav bar shadow
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Community',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
