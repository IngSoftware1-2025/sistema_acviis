import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/custom_checkbox_provider.dart';
import 'package:sistema_acviis/providers/trabajadores_provider.dart';
import 'package:sistema_acviis/frontend/styles/app_colors.dart';
import 'package:sistema_acviis/frontend/widgets/scaffold.dart';

class Trabajador {
  final String nombre;
  final List<String> documentos;

  Trabajador(this.nombre, this.documentos);
}

class ContratosAnexos extends StatefulWidget {
  const ContratosAnexos({super.key});

  @override
  _ContratosAnexosState createState() => _ContratosAnexosState();
}

class _ContratosAnexosState extends State<ContratosAnexos> {
  List<Trabajador> trabajadores = [
    Trabajador("Juan Pérez", ["Contrato.pdf", "Anexo1.pdf"]),
    Trabajador("María González", ["Contrato.pdf", "Finiquito.pdf"]),
  ];

  // Aquí guardamos los índices expandidos
  Set<int> expandido = {};

  @override
  Widget build(BuildContext context) {
    final checkboxProvider = context.watch<CheckboxProvider>();
    final trabajadoresProvider = context.watch<TrabajadoresProvider>();

    final seleccionados = checkboxProvider.checkBoxes // se obtienen los índices de los checkbox seleccionados
      .skip(1)
      .where((cb) => cb.isSelected)
      .map((cb) => cb.index)
      .toList();

    final trabajadoresSeleccionados = seleccionados // se obtienen los índices de los trabajadores seleccionados
      .map((i) => trabajadoresProvider.trabajadores[i])
      .toList();


    return PrimaryScaffold(
      title: 'Contratos y anexos',
      body: Column(
        children: trabajadoresSeleccionados.asMap().entries.map((entry) {
          int index = entry.key;
          var trabajador = entry.value;
          bool isExpanded = expandido.contains(index);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trabajador.nombreCompleto,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            expandido.remove(index);
                          } else {
                            expandido.add(index);
                          }
                        });
                      },
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                if (isExpanded)
                  Column(
                    children: [ // aquí en lugar de este boton solo habría que sacar los diferentes documentos de contratos y anexos de mongo y ponerlos como textbutton.
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Contrato.pdf',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: AppColors.secondary,
                          )
                        ),
                      ),
                    ]
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
