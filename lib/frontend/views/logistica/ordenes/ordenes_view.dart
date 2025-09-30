import 'package:flutter/material.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/lista_ordenes.dart';
import 'package:sistema_acviis/frontend/views/logistica/ordenes/func/search_bar.dart';
import 'package:sistema_acviis/frontend/utils/constants/constants.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';
import 'package:sistema_acviis/frontend/widgets/buttons.dart';
import 'package:sistema_acviis/frontend/utils/filtros/ordenes.dart';

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
                Expanded(child: OrdenesSearchBar()),

                SizedBox(width: normalPadding),

                CascadeButton(
                  title: 'Filtros Órdenes',
                  offset: 0.0,
                  icon: const Icon(Icons.filter_alt_sharp),
                  children: const [
                    SizedBox(
                      width: 400, 
                      child: SingleChildScrollView(
                        child: OrdenesFiltrosDisplay(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: normalPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(height: 10, color: Colors.black),
            ),
          ),
          const Expanded(child: ListaOrdenes()),
        ],
      ),
    );
  }
}
