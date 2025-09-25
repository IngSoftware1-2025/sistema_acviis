import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/lista_ordenes.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/search_bar.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/providers/ordenes_provider.dart';

class OrdenesView extends StatefulWidget {
  const OrdenesView({super.key});

  @override
  State<OrdenesView> createState() => _OrdenesViewState();
}

class _OrdenesViewState extends State<OrdenesView> {
  void _agregarOrden() async {
    final resultado = await Navigator.pushNamed(
      context,
      '/home_page/logistica_view/ordenes_view/agregar_ordenes_view',
    );

    print('🔹 Resultado al volver de AgregarOrdenesView: $resultado');

    if (resultado == true) {
      final ordenesProvider = Provider.of<OrdenesProvider>(context, listen: false);
      await ordenesProvider.fetchOrdenes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Órdenes de Compra',
      body: Column(
        children: [
          Row(
            children: [
              // Botón de Acciones
              CascadeButton(
                title: 'Acciones/Métodos',
                startRight: true,
                offset: 0.0,
                icon: const Icon(Icons.menu),
                children: [
                  // Agregar orden
                  PrimaryButton(
                    text: 'Agregar orden',
                    onPressed: _agregarOrden,
                  ),
                  const SizedBox(height: 8),

                  // Modificar ordenes seleccionadas
                  PrimaryButton(
                    text: 'Modificar órdenes',
                    onPressed: () {
                      final checkboxProvider = Provider.of<CheckboxProvider>(context, listen: false);
                      final ordenesProvider = Provider.of<OrdenesProvider>(context, listen: false);

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

                      final ordenesSeleccionadas =
                          seleccionados.map((i) => ordenesProvider.ordenes[i]).toList();

                      Navigator.pushReplacementNamed(
                        context,
                        '/home_page/logistica_view/ordenes_view/modificar_orden_view',
                        arguments: ordenesSeleccionadas,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Barra de búsqueda
              const Expanded(
                child: OrdenesSearchBar(),
              ),

              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 8),

          // Separador
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(height: 10, color: Colors.black),
            ),
          ),

          // Lista principal
          const ListaOrdenes(),
        ],
      ),
    );
  }
}
