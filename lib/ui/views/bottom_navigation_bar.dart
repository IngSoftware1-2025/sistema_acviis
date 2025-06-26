import 'package:flutter/material.dart';

class NavigationBottomBar extends StatefulWidget {
  const NavigationBottomBar({super.key});
  @override
  State<NavigationBottomBar> createState() => _NavigationBottomBarState();
}

class _NavigationBottomBarState extends State<NavigationBottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navegación según el índice seleccionado
    switch (index) {
      case 0: // Pendientes
        break;
      case 1: // Inicio
        Navigator.pushReplacementNamed(context, '/home_page');
        break;
      case 2: // Nose
        
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.black, // Color para el ítem seleccionado
      unselectedItemColor: Colors.black, // Color para los no seleccionados
      items: const [
        BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
          label: 'Pendientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
          label: 'Null',
        ),
      ],
    );
  }
}