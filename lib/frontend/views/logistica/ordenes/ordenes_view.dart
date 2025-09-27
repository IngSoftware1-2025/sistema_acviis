import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/lista_ordenes.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/search_bar.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';

class OrdenesView extends StatefulWidget {
  const OrdenesView({super.key});

  @override
  State<OrdenesView> createState() => _OrdenesViewState();
}

class _OrdenesViewState extends State<OrdenesView> {
  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Órdenes de Compra',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(normalPadding),
            child: Row(
              children: [
                // Menú de acciones
                CascadeButton(
                  title: 'Acciones/Métodos',
                  startRight: true,
                  offset: 0.0,
                  icon: const Icon(Icons.menu),
                  children: [
                    // Agregar orden
                    PrimaryButton(
                      text: 'Agregar orden',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/home_page/logistica_view/ordenes_view/agregar_ordenes_view',
                        );
                      },
                    ),
                    SizedBox(height: normalPadding),

                    // Dar de baja órdenes seleccionadas
                    PrimaryButton(
                      text: 'Dar de baja órdenes de compra',
                      onPressed: () async {
                        final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                        final ordenesProvider = Provider.of<OrdenesProvider>(context, listen: false);

                        // Obtener índices de órdenes seleccionadas
                        final seleccionados = <int>[];
                        for (int i = 1; i < checkboxProvider.checkBoxes.length; i++) {
                          if (checkboxProvider.checkBoxes[i].isSelected) {
                            seleccionados.add(i - 1);
                          }
                        }

                        if (seleccionados.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debes seleccionar al menos una orden.')),
                          );
                          return;
                        }

                        // Filtrar solo órdenes activas
                        final ordenesSeleccionadas = seleccionados
                            .map((i) => ordenesProvider.ordenes[i])
                            .where((o) => o.estado != 'De baja')
                            .toList();

                        if (ordenesSeleccionadas.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No hay órdenes activas seleccionadas.')),
                          );
                          return;
                        }


                        final idsSeleccionados = ordenesSeleccionadas.map((o) => o.id).toList();
                        try {
                          await ordenesProvider.darDeBaja(idsSeleccionados);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Todas las órdenes activas seleccionadas fueron dadas de baja.')),
                          );
                          // Actualizar checkboxes
                          Provider.of<CheckboxProvider>(context, listen: false)
                              .setCheckBoxes(ordenesProvider.ordenes.length);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hubo un error al dar de baja las órdenes.')),
                          );
                          print("Error al dar de baja las órdenes: $e");
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(height: normalPadding),

                // Barra de búsqueda
                Expanded(child: OrdenesSearchBar()),
              ],
            ),
          ),

          SizedBox(height: normalPadding),

          Padding(
            padding: EdgeInsets.symmetric(vertical: normalPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(height: 10, color: Colors.black),
            ),
          ),

          // Lista de órdenes
          const Expanded(child: ListaOrdenes()),
        ],
      ),
    );
  }
}
