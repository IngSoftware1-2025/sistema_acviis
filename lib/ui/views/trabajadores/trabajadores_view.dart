import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/views/trabajadores/trabajadores_lista.dart';
import 'package:sistema_acviis/utils/constants/constants.dart';
import 'package:sistema_acviis/ui/views/app_bar.dart';
import 'package:sistema_acviis/ui/views/bottom_navigation_bar.dart';
import 'package:sistema_acviis/ui/views/trabajadores/search_bar.dart';

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
    return Scaffold(
      appBar: PersonalizedAppBar(title: 'Trabajadores'),
      body: Padding(
        padding: EdgeInsets.all(normalPadding),
        child: Column(
            children: [

            // Barra de busqueda especializada para Trabajadores
            TrabajadoresSearchBar(), 
            SizedBox(height: normalPadding), // Espacio
            
            // Boton Agregar o Eliminar y Filtro
            Row(
              children: [
              // Boton de Agregar o ELiminar
              Expanded(
                child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/modificar_lista_trabajadores_view');
                },
                child: Center(child: Text('Modificar lista trabajadores')),
                ),
              ),

              // Boton de filtro
              SizedBox(width: 8), // Espacio pequeño entre botones

              SizedBox(
                child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: Size(40, 40),
                ),
                onPressed: () {},
                child: Icon(Icons.filter_alt_sharp, size: 22),
                ),
              ),
              ],
            ),
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
      ),
      bottomNavigationBar: NavigationBottomBar(),
    );
  }
}