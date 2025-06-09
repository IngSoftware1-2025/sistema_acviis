import 'package:flutter/material.dart';
import 'package:sistema_acviis/ui/widgets/scaffold.dart';

class Trabajador {
  final String nombre;
  final List<String> documentos;
  bool isExpanded;

  Trabajador(this.nombre, this.documentos, {this.isExpanded = false});
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

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Contratos y anexos',
      body: ListView(
        children: [
          ExpansionPanelList(
            expansionCallback: (index, isExpanded) {
              setState(() {
                trabajadores[index].isExpanded = !isExpanded;
              });
            },
            children: trabajadores.map<ExpansionPanel>((trabajador) {
              return ExpansionPanel(
                headerBuilder: (context, isExpanded) => ListTile(
                  title: Text(trabajador.nombre),
                ),
                body: Column(
                  children: trabajador.documentos.map((doc) {
                    return ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text(doc),
                      onTap: () {
                        // Acción al tocar documento
                      },
                    );
                  }).toList(),
                ),
                isExpanded: trabajador.isExpanded,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}