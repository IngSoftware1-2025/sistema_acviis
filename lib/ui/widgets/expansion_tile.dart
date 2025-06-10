import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';

class PersonalizedExpansionTile extends StatefulWidget {
  final Trabajador trabajador;
  final Widget? trailing; // <-- Agregado

  const PersonalizedExpansionTile({
    super.key,
    required this.trabajador,
    this.trailing, // <-- Agregado
  });

  @override
  State<PersonalizedExpansionTile> createState() => _PersonalizedExpansionTileState();
}

class _PersonalizedExpansionTileState extends State<PersonalizedExpansionTile> {
  @override
  Widget build(BuildContext context) {
    final t = widget.trabajador;
    return ExpansionTile(
      title: Text(t.nombreCompleto),
      leading: const Icon(Icons.keyboard_arrow_down),
      trailing: widget.trailing,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${t.id}'),
              Text('Nombre: ${t.nombreCompleto}'),
              Text('Estado Civil: ${t.estadoCivil}'),
              Text('RUT: ${t.rut}'),
              Text('Fecha de Nacimiento: ${t.fechaDeNacimiento.toLocal().toString().split(' ')[0]}'),
              Text('Dirección: ${t.direccion}'),
              Text('Correo Electrónico: ${t.correoElectronico}'),
              Text('Sistema de Salud: ${t.sistemaDeSalud}'),
              Text('Previsión AFP: ${t.previsionAfp}'),
              Text('Obra en la que trabaja: ${t.obraEnLaQueTrabaja}'),
              Text('Rol que asume en la obra: ${t.rolQueAsumeEnLaObra}'),
              //Text('Estado trabajador: ${t.estadoTrabajador}'),
            ],
          ),
        ),
      ],
    );
  }
}
