import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/widgets/cards.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';
import 'package:sistema_acviis/ui/widgets/buttons.dart';


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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PersonalizedAppBar(title: 'Home',),
      body: Container(
        width: double.infinity,
        color: AppColors.background, // Color de fondo body
        child: Container(
          color: AppColors.background,
          child: Padding(
            padding: EdgeInsets.all(normalPadding),
            child: GridCards(
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
                  'title': 'Contratos',
                  'description': 'Funciones de logística: Herramientas, EPP, Vehículos, etc',
                  'icon': Icon(Icons.inventory_outlined, color: AppColors.primaryDarker)
                },
                {
                  'title': 'Obras',
                  'description': 'Funciones de obras: Crear, Charlas, Asistencia, etc',
                  'icon': Icon(Icons.construction, color: AppColors.primaryDarker)
                },
                {
                  'title': 'Opciones',
                  'description': 'Ajustes de la app',
                  'icon': Icon(Icons.settings, color: AppColors.primaryDarker)
                },

              ])
            /*Column( // Aqui iran todas las vistas iniciales por categoria (trabajador, contrato, etc)
              children: [
            
                SizedBox(height: normalPadding,), // Un espacio
                Column(
                  children: [
                    Row(
                      children: [
                        PrimaryCard(
                          title: 'Trabajadores',
                          description: 'Funciones de trabajador: Modificar, Agregar, Eliminar, etc',
                          icon: Icon(Icons.engineering, color: AppColors.primaryDarker, size: 100)
                        ),
                        PrimaryCard(
                          title: 'Contratos',
                          description: 'Funciones de contratos: Modificar, Agregar, Eliminar, etc',
                          icon: Icon(Icons.description, color: AppColors.primaryDarker, size: 100)
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        PrimaryCard(
                          title: 'Finanzas',
                          description: 'Funciones de trabajador: Modificar, Agregar, Eliminar, etc',
                          icon: Icon(Icons.attach_money, color: AppColors.primaryDarker, size: 100)
                        ),
                        PrimaryCard(
                          title: 'Contratos',
                          description: 'Funciones de contratos: Modificar, Agregar, Eliminar, etc',
                          icon: Icon(Icons.inventory_outlined, color: AppColors.primaryDarker, size: 100)
                        ),
                      ],
                    ),                 
                  ],
                ), 
              ]
            ), */
          )
        ),
      ),
      bottomNavigationBar: NavigationBottomBar(), // Barra de navegacion
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