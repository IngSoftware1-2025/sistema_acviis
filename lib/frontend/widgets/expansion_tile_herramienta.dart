import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/herramienta.dart';

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
          subtitle: Text(herramienta.garantia != null ? herramienta.garantia!.toLocal().toString().split(' ')[0] : 'Sin garantía'),
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
          title: Text('Asignación inicio'),
          subtitle: Text(herramienta.asigInicio != null ? herramienta.asigInicio!.toLocal().toString().split(' ')[0] : 'No asignada'),
        ),
        ListTile(
          title: Text('Asignación fin'),
          subtitle: Text(herramienta.asigFin != null ? herramienta.asigFin!.toLocal().toString().split(' ')[0] : 'No asignada'),
        ),
      ],
    );
  }
}
