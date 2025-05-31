import 'package:flutter/material.dart';
import 'package:sistema_acviis/constants/constants.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';


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
      appBar: PersonalizedAppBar(title: 'Home'),
      body: Container(
        color: Colors.white, // Color de fondo body
        child: Padding(
          padding: EdgeInsets.all(normalPadding), // El padding esta en constants.dart
          child: Expanded(
            child: Container(
              color: colorAcviis,
              child: Padding(
                padding: EdgeInsets.all(normalPadding),
                child: Column( // Aqui iran todas las vistas iniciales por categoria (trabajador, contrato, etc)
                  children: [
                
                    SizedBox(height: normalPadding,), // Un espacio
                    // Boton que redirige a trabajadores
                    ElevatedButton( // El estilo se decidira mas adelante (Probablemente cambiando el Widget)
                      onPressed: () {
                        Navigator.pushNamed(context, '/trabajadores_view');
                      },
                      child: Center(child: Text('Trabajadores'))
                    ),
                    SizedBox(height: normalPadding,), // Un espacio

                    // Boton que redirige a contratos
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/contratos_view');
                      },
                      child: Center(child: Text('Contratos')),
                    )
                  ]
                ),
              )
            )
          )
        )
      ),
    );
  }
}