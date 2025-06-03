import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/home_page.dart';
import 'package:sistema_acviis/constants/routes.dart';

// No es necesario inicializar supabase porque las peticiones se haran al servidor de JS, y este conecta con la base de datos
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
      routes: routes,
    );
  }
}
