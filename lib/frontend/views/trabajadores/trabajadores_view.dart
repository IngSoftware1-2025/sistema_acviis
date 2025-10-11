import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/lista_trabajadores.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/views/trabajadores/func/search_bar.dart';
import 'package:sistema_acviis/frontend/utils/filtros/contratos.dart';
import 'package:sistema_acviis/frontend/utils/filtros/trabajadores.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:provider/provider.dart';

class TrabajadoresView extends StatefulWidget {
  const TrabajadoresView({
    super.key
  });
  @override
  State<TrabajadoresView> createState() => _TrabajadoresViewState();
}

class _TrabajadoresViewState extends State<TrabajadoresView> {
  int vistaSeleccionada = 0;
  Widget vista = ListaTrabajadores();

  @override
  Widget build(BuildContext context){
    return PrimaryScaffold(
      title: 'Trabajadores',
      body: Column(
        children: [
        // Parte superior Lista de trabajadores
        Row(
          children: [
            // Acciones lista de trabajadores
            CascadeButton(
              title: 'Acciones/Metodos',
              startRight: true,
              offset: 0.0, 
              icon: Icon(Icons.menu),
              children: [
                // Botón para alternar a la vista de contratos.
                PrimaryButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/contratos_anexos');
                  },
                  text: 'Alternar vista',
                ),

                SizedBox(height: normalPadding),

                // Boton Agregar trabajador
                PrimaryButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home_page/trabajadores_view/agregar_trabajador_view');
                  },
                  text: 'Agregar trabajador',
                ),

                SizedBox(height: normalPadding),

                // Botón de modificar trabajadores
                PrimaryButton(
                  onPressed: () {
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);

                  // Obtiene los índices seleccionados (excepto el primero, que es "select all")
                  final seleccionados = <int>[];
                  for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                    if (checkboxProvider.checkBoxes[i].isSelected) {
                      seleccionados.add(i - 1); // -1 porque el primero es "select all"
                    }
                  }

                  if (seleccionados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debes seleccionar al menos un trabajador.')),
                    );
                    return;
                  }

                  // Obtiene los trabajadores seleccionados
                  final trabajadoresSeleccionados = seleccionados
                      .map((i) => trabajadoresProvider.trabajadores[i])
                      .toList();

                  Navigator.pushReplacementNamed(
                    context,
                    '/home_page/trabajadores_view/modificar_trabajadores_view',
                    arguments: trabajadoresSeleccionados,
                  );
                },
                  text: 'Modificar trabajador',
                ),

                SizedBox(height: normalPadding),

                // Botón Eliminar Contratos (SOLO UNO, correctamente implementado)
                PrimaryButton(
                  onPressed: () {
                    final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                    final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);

                    // Obtiene los índices seleccionados (excepto el primero, que es "select all")
                    final seleccionados = <int>[];
                    for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                      if (checkboxProvider.checkBoxes[i].isSelected) {
                        seleccionados.add(i - 1); // -1 porque el primero es "select all"
                      }
                    }

                    if (seleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Debes seleccionar al menos un trabajador.')),
                      );
                      return;
                    }

                    // Obtiene los trabajadores seleccionados
                    final trabajadoresSeleccionados = seleccionados
                        .map((i) => trabajadoresProvider.trabajadores[i])
                        .toList();

                    Navigator.pushReplacementNamed(
                      context,
                      '/home_page/trabajadores_view/eliminar_contratos_view',
                      arguments: {
                        'trabajadores': trabajadoresSeleccionados,
                      },
                    );
                  },
                  text: 'Eliminar Contratos',
                ),

                SizedBox(height: normalPadding), // Espacio entre los botones

                // Boton Eliminar trabajadores
                PrimaryButton(
                  onPressed: () {
                    final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                    final trabajadoresProvider = Provider.of<TrabajadoresProvider>(context, listen: false);

                    // Obtiene los índices seleccionados (excepto el primero, que es "select all")
                    final seleccionados = <int>[];
                    for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                      if (checkboxProvider.checkBoxes[i].isSelected) {
                        seleccionados.add(i - 1); // -1 porque el primero es "select all"
                      }
                    }

                    if (seleccionados.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Debes seleccionar al menos un trabajador.')),
                      );
                      return;
                    }

                    // Obtiene los trabajadores seleccionados
                    final trabajadoresSeleccionados = seleccionados
                        .map((i) => trabajadoresProvider.trabajadores[i])
                        .toList();

                    Navigator.pushReplacementNamed(
                      context,
                      '/home_page/trabajadores_view/eliminar_trabajador_view',
                      arguments: trabajadoresSeleccionados,
                    );
                  },
                  text: 'Eliminar trabajadores',
                ),
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
              title: 'Filtros Trabajador',
              offset: 0.0,
              icon: Icon(Icons.filter_alt_sharp),
              title2: 'Filtros Contratos',
              children2: [
                ContratosFiltrosDisplay(),
              ],
              children: [
                TrabajadorFiltrosDisplay(),
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
        // Lista de trabajadores o contratos
        ListaTrabajadores(),
        ],
      ),
    );
  }
}