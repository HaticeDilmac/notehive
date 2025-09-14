import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      indicatorColor: Colors.grey[200],
      shadowColor: Colors.black.withOpacity(0.1),
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.note_outlined,
            color: Colors.grey[600],
          ),
          selectedIcon: Icon(
            Icons.note,
            color: Colors.black,
          ),
          label: 'Notlar',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.settings_outlined,
            color: Colors.grey[600],
          ),
          selectedIcon: Icon(
            Icons.settings,
            color: Colors.black,
          ),
          label: 'Ayarlar',
        ),
      ],
    );
  }
}
