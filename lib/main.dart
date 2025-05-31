import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/home_page.dart';
import 'package:sistema_acviis/constants/routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HomePage(),
      ),
      routes: routes, // Para el redireccionamiento dentro del sistema entero
    );
  }
}
