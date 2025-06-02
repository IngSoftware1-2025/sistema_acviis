import 'package:flutter/material.dart';
import 'package:sistema_acviis/constants/constants.dart';
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
            child: Column( // Aqui iran todas las vistas iniciales por categoria (trabajador, contrato, etc)
              children: [
            
                SizedBox(height: normalPadding,), // Un espacio
        
                // Boton que redirige a trabajadores
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
                SizedBox(height: normalPadding,), // Un espacio

                SecondaryButton(
                  onPressed: () {},
                  text: "Obras",
                  size: Size(700, 50),
                ),
              ]
            ),
          )
        ),
      ),
      bottomNavigationBar: NavigationBottomBar(), // Barra de navegacion
    );
  }
}