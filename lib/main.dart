import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/home_page.dart';
import 'package:sistema_acviis/constants/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de cualquier llamada a Flutter
  // (es necesario cuando main es async y se usa runApp o plugins antes de runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el cliente de Supabase
  await Supabase.initialize(
    url: 'https://rldouudlsyrhksbsrtod.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsZG91dWRsc3lyaGtzYnNydG9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4NDMxMjMsImV4cCI6MjA2NDQxOTEyM30.yqGzKWrbJYin6fH3pjqfqtE8nqflTv3imooYJZ9GO-A',
    //esta es la clave del proyecto de Supabase que cree, no se si les sirva la misma
  );

  // Corre la aplicación
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
