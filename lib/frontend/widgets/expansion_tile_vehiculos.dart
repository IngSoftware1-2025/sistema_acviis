import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/vehiculo.dart';
import 'package:intl/intl.dart';

class ExpansionTileVehiculos extends StatelessWidget {
  final Vehiculo vehiculo;

  const ExpansionTileVehiculos({Key? key, required this.vehiculo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(vehiculo.patente),
      subtitle: Text('Tipo: ${vehiculo.tipo} | Estado: ${vehiculo.estado}'),
      children: [
        ListTile(
          title: const Text('Permiso de circulación'),
          subtitle: Text(vehiculo.permisoCirc),
        ),
        ListTile(
          title: const Text('Revisión técnica'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(vehiculo.revisionTecnica)),
        ),
        ListTile(
          title: const Text('Revisión de gases'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(vehiculo.revisionGases)),
        ),
        ListTile(
          title: const Text('Última mantención'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(vehiculo.ultimaMantencion)),
        ),
        ListTile(
          title: const Text('Descripción de mantención'),
          subtitle: Text(vehiculo.descripcionMant ?? 'Sin descripción'),
        ),
        ListTile(
          title: const Text('Próxima mantención'),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(vehiculo.proximaMantencion)),
        ),
        ListTile(
          title: const Text('Capacidad (kg)'),
          subtitle: Text(vehiculo.capacidadKg.toString()),
        ),
        ListTile(
          title: const Text('Tipo de neumáticos'),
          subtitle: Text(vehiculo.neumaticos),
        ),
        ListTile(
          title: const Text('Rueda de repuesto'),
          subtitle: Text(vehiculo.ruedaRepuesto ? 'Sí' : 'No'),
        ),
        ListTile(
          title: const Text('Observaciones'),
          subtitle: Text(vehiculo.observaciones ?? 'Sin observaciones'),
        ),
      ],
    );
  }
}
