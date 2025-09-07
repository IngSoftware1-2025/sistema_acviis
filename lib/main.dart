import 'package:flutter/material.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/views/home_page.dart';
import 'package:sistema_acviis/frontend/utils/constants/routes.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/providers/contratos_provider.dart';
import 'package:sistema_acviis/providers/comentarios_provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';

// No es necesario inicializar supabase porque las peticiones se haran al servidor de JS, y este conecta con la base de datos
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrabajadoresProvider()),
        ChangeNotifierProvider(create: (_) => ProveedoresProvider()),
        ChangeNotifierProvider(create: (_) => ContratosProvider()),
        ChangeNotifierProvider(create: (_) => CheckboxProvider()),
        ChangeNotifierProvider(create: (_) => ComentariosProvider()),
        ChangeNotifierProvider(create: (_) => HerramientasProvider()),
      ],
      child: MainApp(),
    ),
  );
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
