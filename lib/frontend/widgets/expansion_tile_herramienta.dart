import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/herramienta.dart';
import 'package:intl/intl.dart';

class ExpansionTileHerramienta extends StatelessWidget {
  final Herramienta herramienta;

  const ExpansionTileHerramienta({Key? key, required this.herramienta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(herramienta.tipo),
      subtitle: Text('Estado: ${herramienta.estado}'),
      children: [
        ListTile(
          title: Text('Garantía'),
          subtitle: Text(
            herramienta.garantia != null 
            ? DateFormat('yyyy-MM-dd').format(herramienta.garantia!) :
            'Sin garantía',
          ),
        ),
        ListTile(
          title: Text('Cantidad'),
          subtitle: Text(herramienta.cantidad.toString()),
        ),
        ListTile(
          title: Text('Obra asignada'),
          subtitle: Text(herramienta.obraAsig ?? 'Sin asignar'),
        ),
        ListTile(
          title: Text('Inicio de asignación'),
          subtitle: Text(
            herramienta.asigInicio != null 
            ? DateFormat('yyyy-MM-dd').format(herramienta.asigInicio!) :
            'No asignada',
          ),
        ),
        ListTile(
          title: Text('Fin de asignación'),
          subtitle: Text(
            herramienta.asigFin != null 
            ? DateFormat('yyyy-MM-dd').format(herramienta.asigFin!) :
            'No asignada',
          ),
        ),
      ],
    );
  }
}
