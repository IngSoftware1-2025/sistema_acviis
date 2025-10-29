import 'package:flutter/material.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/views/home_page.dart';
import 'package:sistema_acviis/frontend/utils/constants/routes.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/finanzas_obra_provider.dart';
import 'package:sistema_acviis/providers/herramientas_provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/providers/contratos_provider.dart';
import 'package:sistema_acviis/providers/comentarios_provider.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:sistema_acviis/providers/proveedores_provider.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';
import 'package:sistema_acviis/providers/itemizados_provider.dart';
import 'package:sistema_acviis/providers/pagos_provider.dart';
import 'package:sistema_acviis/providers/notificaciones_provider.dart';
import 'package:sistema_acviis/providers/obras_provider.dart';
import 'package:sistema_acviis/providers/recursos_obra_provider.dart';

// Clave global para acceder al ScaffoldMessenger sin un BuildContext
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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
        ChangeNotifierProvider(create: (_) => EppProvider()),
        ChangeNotifierProvider(create: (_) => HerramientasProvider()),
        ChangeNotifierProvider(create:  (_) => VehiculosProvider()),
        ChangeNotifierProvider(create: (_) => OrdenesProvider()),
        ChangeNotifierProvider(create: (_) => ItemizadosProvider()),
        ChangeNotifierProvider(create: (_) => PagosProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
        ChangeNotifierProvider(create: (_) => ObrasProvider()),
        ChangeNotifierProvider(create: (_) => RecursosObraProvider()),
        ChangeNotifierProvider(create: (_) => FinanzasObraProvider())
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
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey, // Asignamos la clave global
      home: Scaffold(
        body: HomePage(),
      ),
      routes: routes,
    );
  }
}
