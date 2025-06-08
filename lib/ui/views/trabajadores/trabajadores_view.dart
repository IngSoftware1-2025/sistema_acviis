import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/trabajadores/func/lista_trabajadores.dart';
import 'package:sistema_acviis/ui/widgets/buttons.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/ui/views/trabajadores/func/search_bar.dart';

class TrabajadoresView extends StatefulWidget {
  const TrabajadoresView({
    super.key
  });
  @override
  State<TrabajadoresView> createState() => _TrabajadoresViewState();
}

class _TrabajadoresViewState extends State<TrabajadoresView> {
  @override
  Widget build(BuildContext context){
    return PrimaryScaffold(
      title: 'Trabajadores',
      body: Column(
        children: [
        
        // Barra de busqueda especializada para Trabajadores
        Row(
          children: [
            // Acciones lista de trabajadores
            CascadeButton(
              title: 'Acciones/Metodos',
              startRight: true,
              offset: 0.0, 
              icon: Icon(Icons.menu),
              children: [
                // Boton Agregar trabajador
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/agregar_trabajador_view');
                  },
                  child: Center(child: Text('Agregar trabajador')),
                ),

                SizedBox(height: normalPadding), // Espacio entre botones

                // Boton Eliminar trabajadores
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/eliminar_trabajador_view');
                  }, 
                  child: Center(child: Text('Eliminar trabajadores')))
              ],
            ),
            SizedBox(width: normalPadding), // Espacio pequeño entre botones

            // Search bar expandido
            Expanded(
              child: TrabajadoresSearchBar(),
            ),
            SizedBox(width: normalPadding), // Espacio pequeño entre botones

            // Filtros
            CascadeButton(
              title: 'Filtros',
              offset: 0.0,
              icon: Icon(Icons.filter_alt_sharp),
              children: [

              ],
            )
          ],
        ), 
        SizedBox(height: normalPadding), // Espacio

        // Divider con bordes redondeados
        Padding(
          padding: EdgeInsets.symmetric(vertical: normalPadding),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 10,
            color: Colors.black,
          ),
          ),
        ),
        // ######### Aqui Comienza la lista de trabajadores #########
        // Lista de trabajadores
        ListaTrabajadores(),
        ],
      ),
    );
  }
}