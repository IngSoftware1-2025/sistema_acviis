import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/widgets/cards.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/vertical_side_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context){
    final opciones = [
      {
        'title': 'Trabajadores',
        'description': 'Funciones de trabajador: Modificar, Agregar, Eliminar, etc',
        'icon': Icon(Icons.engineering, color: AppColors.primaryDarker),
        'screen': '/home_page/trabajadores_view'
      },
      /*{
        'title': 'Contratos',
        'description': 'Funciones de contratos: Modificar, Agregar, Eliminar, etc',
        'icon': Icon(Icons.description, color: AppColors.primaryDarker),
        'screen': '/home_page/contratos_view'
      },*/
      {
        'title': 'Finanzas',
        'description': 'Funciones de finanzas: Modificar, Agregar, Eliminar, etc',
        'icon': Icon(Icons.attach_money, color: AppColors.primaryDarker),
        'screen': '/home_page/finanzas_main_view'
      },
      {
        'title': 'Logística',
        'description': 'Funciones de logística: Herramientas, EPP, Vehículos, etc',
        'icon': Icon(Icons.inventory_outlined, color: AppColors.primaryDarker),
        'screen': '/home_page/logistica_view'
      },
      {
        'title': 'Obras',
        'description': 'Funciones de obras: Crear, Charlas, Asistencia, etc',
        'icon': Icon(Icons.construction, color: AppColors.primaryDarker),
      },
/*       {
        'title': 'Opciones',
        'description': 'Ajustes de la app',
        'icon': Icon(Icons.settings, color: AppColors.primaryDarker)
      }, */
      {
        'title': 'Proveedores',
        'description': 'Funciones de proveedor: Modificar, Agregar, Eliminar, etc',
        'icon': Icon(Icons.store, color: AppColors.primaryDarker),
        'screen': '/home_page/proveedores_view'
      },
    ];

    return PrimaryScaffold(
      title: 'Home',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridCards(opciones: opciones),
          ),
          // Si quieres la barra lateral de íconos, puedes agregarla aquí después de que el grid funcione.
          // const SizedBox(width: 24),
          // VerticalSideBar(items: opciones),
        ],
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
