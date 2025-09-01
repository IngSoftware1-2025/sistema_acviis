import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/cards.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';



class HomePage extends StatefulWidget {
  const HomePage({
    super.key
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context){
    return PrimaryScaffold(
      title: 'Home',
      body: GridCards(
        opciones: [
          {
            'title': 'Trabajadores',
            'description': 'Funciones de trabajador: Modificar, Agregar, Eliminar, etc',
            'icon': Icon(Icons.engineering, color: AppColors.primaryDarker),
            'screen': '/home_page/trabajadores_view'
          },
          {
            'title': 'Contratos',
            'description': 'Funciones de contratos: Modificar, Agregar, Eliminar, etc',
            'icon': Icon(Icons.description, color: AppColors.primaryDarker),
            'screen': '/home_page/contratos_view'
          },
          {
            'title': 'Finanzas',
            'description': 'Funciones de trabajador: Modificar, Agregar, Eliminar, etc',
            'icon': Icon(Icons.attach_money, color: AppColors.primaryDarker)
          },
          {
            'title': 'Logística',
            'description': 'Funciones de logística: Herramientas, EPP, Vehículos, etc',
            'icon': Icon(Icons.inventory_outlined, color: AppColors.primaryDarker)
          },
          {
            'title': 'Obras',
            'description': 'Funciones de obras: Crear, Charlas, Asistencia, etc',
            'icon': Icon(Icons.construction, color: AppColors.primaryDarker),
            'screen': '/home_page/herramientas_view'
          },
          {
            'title': 'Opciones',
            'description': 'Ajustes de la app',
            'icon': Icon(Icons.settings, color: AppColors.primaryDarker)
          },
        ]
      ),
    );
  }
}






// Boton que redirige a trabajadores
/*
PrimaryButton( // El estilo se decidira mas adelante (Probablemente cambiando el Widget)
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view');
  },
  text: "Trabajadores",
  size: Size(700, 50),
),
SizedBox(height: normalPadding,), // Un espacio

// Boton que redirige a contratos
BorderButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, '/home_page/contratos_view');
  },
  text: "Contratos",
  size: Size(700, 50),
),
SizedBox(height: normalPadding,), // Un espacio

PrimaryButton(
  onPressed: () {},
  text: "Finanzas",
  size: Size(700, 50),
),
SizedBox(height: normalPadding,), // Un espacio

BorderButton(
  onPressed: () {},
  text: "Logística",
  size: Size(700, 50),
),
SizedBox(height: normalPadding,), // Un espacio */