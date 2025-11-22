import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/logistica/func/lista_epp.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/views/logistica/func/search_bar_epp.dart';
import 'package:sistema_acviis/frontend/utils/filtros/epp.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/epp_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/models/epp.dart';


class EppView extends StatefulWidget {
  const EppView({super.key});

  @override
  State<EppView> createState() => _EppViewState();
}

class _EppViewState extends State<EppView> {
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'EPP - Equipos de Protección Personal',
      body: Column(
        children: [
          // Parte superior - Acciones y búsqueda
          Row(
            children: [
              // Acciones EPP
              CascadeButton(
                title: 'Acciones/Métodos',
                startRight: true,
                offset: 0.0,
                icon: Icon(Icons.menu),
                children: [
                  // Botón Agregar EPP
                  PrimaryButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context, 
                        '/home_page/logistica_view/epp_view/agregar_epp_view'
                      );
                    },
                    text: 'Agregar EPP',
                  ),

                  SizedBox(height: normalPadding),

                  // Botón Modificar EPP
                  PrimaryButton(
                    onPressed: () {
                      final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                      final eppProvider = Provider.of<EppProvider>(context, listen: false);

                      // Obtiene los índices seleccionados (excepto el primero, que es "select all")
                      final seleccionados = <int>[];
                      for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                        if (checkboxProvider.checkBoxes[i].isSelected) {
                          seleccionados.add(i - 1); // -1 porque el primero es "select all"
                        }
                      }

                      if (seleccionados.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Debes seleccionar al menos un EPP.')),
                        );
                        return;
                      }

                      if (seleccionados.length > 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selecciona solo un EPP para modificar.')),
                        );
                        return;
                      }

                      // Obtiene el EPP seleccionado
                      final eppSeleccionado = eppProvider.epps[seleccionados.first];

                      Navigator.pushNamed(
                        context,
                        '/home_page/logistica_view/epp_view/modificar_epp_view',
                        arguments: eppSeleccionado,
                      );
                    },
                    text: 'Modificar EPP',
                  ),

                  SizedBox(height: normalPadding),

// Botón Eliminar EPP (modificado)
PrimaryButton(
  onPressed: () async {
    final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
    final eppProvider = Provider.of<EppProvider>(context, listen: false);

    // Obtiene los índices seleccionados (excepto el primero, que es "select all")
    final seleccionados = <int>[];
    for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
      if (checkboxProvider.checkBoxes[i].isSelected) {
        seleccionados.add(i - 1); // -1 porque el primero es "select all"
      }
    }

    if (seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar al menos un EPP.')),
      );
      return;
    }

    // Obtiene los EPPs seleccionados
    final eppsSeleccionados = seleccionados
        .map((i) => eppProvider.epps[i])
        .toList();

    // ⚡ CERRAR EL MENÚ ANTES DE MOSTRAR EL DIÁLOGO:
    Navigator.of(context).pop(); // Cierra el CascadeButton
    
    // ⚡ PEQUEÑO DELAY PARA ASEGURAR QUE EL MENÚ SE CIERRE COMPLETAMENTE:
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Mostrar diálogo de confirmación
    await _mostrarDialogoEliminarMultiples(context, eppsSeleccionados, eppProvider);
  },
  text: 'Eliminar EPP',
),


                ],
              ),
              
              SizedBox(width: normalPadding),

              // Search bar expandido
              Expanded(
                child: EppSearchBar(),
              ),
              
              SizedBox(width: normalPadding),
              
              // Filtros EPP
              CascadeButton(
                title: 'Filtros EPP',
                offset: 0.0,
                icon: Icon(Icons.filter_alt_sharp),
                children: [
                  EppFiltrosDisplay(),
                ],
              )
            ],
          ),
          
          SizedBox(height: normalPadding),

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
          
          // ######### Aquí comienza la lista de EPPs #########
          ListaEpp(),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoEliminarMultiples(
    BuildContext context, 
    List<EPP> eppsSeleccionados, 
    EppProvider eppProvider
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación Múltiple'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que deseas eliminar ${eppsSeleccionados.length} EPP(s)?'),
                SizedBox(height: 16),
                Text(
                  'EPPs a eliminar:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...eppsSeleccionados.map((epp) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${epp.tipo} (${epp.cantidadTotal} unidades)'),
                )).toList(),
                SizedBox(height: 16),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Eliminar Todos', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // ⚡ GUARDAR REFERENCIA
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                Navigator.of(context).pop();
                
                final ids = eppsSeleccionados.map((epp) => epp.id!).toList();
                final success = await eppProvider.eliminarEppsMultiples(ids);
                
                // ⚡ USAR REFERENCIA GUARDADA
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${eppsSeleccionados.length} EPP(s) eliminados exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Limpiar selección
                  final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                  checkboxProvider.setCheckBoxes(eppProvider.epps.length);
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar EPPs: ${eppProvider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
