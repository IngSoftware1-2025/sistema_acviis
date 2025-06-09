import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';

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
    return PrimaryScaffold(
      title: 'Contratos y anexos',
      body: Column(
        children: trabajadores.asMap().entries.map((entry) {
          int index = entry.key;
          Trabajador trabajador = entry.value;
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
                        trabajador.nombre,
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
                    children: trabajador.documentos.map((doc) {
                      return TextButton(
                        onPressed: () {},
                        child: Text(
                          doc,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: AppColors.secondary,
                            
                          )
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
