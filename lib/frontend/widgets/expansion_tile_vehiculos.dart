import 'package:flutter/material.dart';
import 'package:sistema_acviis/models/vehiculo.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:sistema_acviis/backend/controllers/vehiculos/vehiculo_permisos.dart';
import 'package:sistema_acviis/backend/controllers/vehiculos/update_vehiculo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:sistema_acviis/providers/vehiculos_provider.dart';

class ExpansionTileVehiculos extends StatelessWidget {
  final Vehiculo vehiculo;

  const ExpansionTileVehiculos({Key? key, required this.vehiculo}) : super(key: key);

  Future<void> _subirPermisoCirculacion(BuildContext context) async {
    try {
      // Seleccionar archivo PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        
        // Mostrar diálogo de carga
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(child: CircularProgressIndicator()),
        );

        // Subir archivo a MongoDB
        final permisoId = await subirPermisoCirculacion(
          vehiculoId: vehiculo.id,
          archivo: file,
        );

        // Actualizar el vehículo en PostgreSQL con el permisoId
        await updateVehiculo({
          'id': vehiculo.id,
          'patente': vehiculo.patente,
          'permiso_id': permisoId,
          'revision_tecnica': vehiculo.revisionTecnica.toIso8601String(),
          'revision_gases': vehiculo.revisionGases.toIso8601String(),
          'ultima_mantencion': vehiculo.ultimaMantencion.toIso8601String(),
          'descripcion_mant': vehiculo.descripcionMant,
          'capacidad_kg': vehiculo.capacidadKg,
          'neumaticos': vehiculo.neumaticos,
          'rueda_repuesto': vehiculo.ruedaRepuesto,
          'observaciones': vehiculo.observaciones,
          'estado': vehiculo.estado,
          'proxima_mantencion': vehiculo.proximaMantencion.toIso8601String(),
          'tipo': vehiculo.tipo,
        });

        // Actualizar la lista de vehículos
        if (!context.mounted) return;
        await Provider.of<VehiculosProvider>(context, listen: false).fetchVehiculos();

        // Cerrar diálogo de carga
        if (!context.mounted) return;
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de circulación subido correctamente')),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) Navigator.of(context).pop();
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir permiso: $e')),
      );
    }
  }

  Future<void> _verPermisoCirculacion(BuildContext context) async {
    if (vehiculo.permisoId == null || vehiculo.permisoId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este vehículo no tiene permiso de circulación cargado')),
      );
      return;
    }

    try {
      final url = obtenerUrlPermisoCirculacion(vehiculo.permisoId!);
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el permiso de circulación')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir permiso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(vehiculo.patente),
      subtitle: Text('Tipo: ${vehiculo.tipo} | Estado: ${vehiculo.estado}'),
      children: [
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
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _subirPermisoCirculacion(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir Permiso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: vehiculo.permisoId != null 
                    ? () => _verPermisoCirculacion(context)
                    : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Ver Permiso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
