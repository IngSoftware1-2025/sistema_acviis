import 'package:flutter/material.dart';
import 'package:sistema_acviis/constants/constants.dart';
import 'package:sistema_acviis/test/supabase_test.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';

class ModificarListaTrabajadoresView extends StatefulWidget {
  const ModificarListaTrabajadoresView({
    super.key,
  });

  @override
  State<ModificarListaTrabajadoresView> createState() => _ModificiarListaTrabajadoresViewState();
}

class _ModificiarListaTrabajadoresViewState extends State<ModificarListaTrabajadoresView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Modificar lista de trabajadores'),
      body: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/modificar_lista_trabajadores_view/agregar_trabajador_view');
              },
              child: Center(child: Text('Agregar trabajador/es'))
            ),
            SizedBox(height: normalPadding),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/modificar_lista_trabajadores_view/eliminar_trabajador_view');
              },
              child: Center(child: Text('Eliminar trabajador/es'))
            ),

            SizedBox(height: normalPadding),

            ElevatedButton( // Boton de testing :V
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GetTrabajador()),
                );
              },
              child: Center(child: Text('GetTrabajadores'))
            )
          ]
        )
      ),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}