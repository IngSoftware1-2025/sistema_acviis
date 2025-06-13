import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/trabajador.dart';
import 'package:sistema_acviis/ui/styles/app_colors.dart';

class PersonalizedExpansionTile extends StatefulWidget {
  final Trabajador trabajador;
  final Widget? trailing;
  final VoidCallback? pdfCallback;  

  const PersonalizedExpansionTile({
    super.key,
    required this.trabajador,
    this.trailing,
    this.pdfCallback, 
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
              Text('Estado en la empresa: ${t.estado}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Generar ficha PDF', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                onPressed: widget.pdfCallback ?? () {}, 
              ),
            ],
          ),
        ),
      ],
    );
  }
}
