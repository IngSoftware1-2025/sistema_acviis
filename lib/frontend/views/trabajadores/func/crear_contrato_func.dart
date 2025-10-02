import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/contratos/create_contrato.dart';

Future<void> mostrarDialogoCrearContrato({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  // Verificar si ya tiene un contrato activo
  if ((trabajador.contratos ?? []).any((contrato) => contrato['estado'] == 'Activo')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El trabajador ya tiene un contrato activo vinculado.')),
    );
    return;
  }

  final plazoController = TextEditingController();
  String estadoSeleccionado = 'Activo';
  bool camposInvalidos = false;
  

  // Primer diálogo: solicitar datos del contrato
  final confirmar = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear nuevo contrato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del trabajador:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
              Text('RUT: ${trabajador.rut ?? ''}'),
              const SizedBox(height: 16),
              const Text(
                'Datos del contrato:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: plazoController,
                decoration: InputDecoration(
                  labelText: 'Plazo del contrato',
                  errorText: camposInvalidos && plazoController.text.trim().isEmpty
                      ? 'Campo obligatorio'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (camposInvalidos) setState(() => camposInvalidos = false);
                },
              ),
              const SizedBox(height: 12),
              // Se crea siempre como activo
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Estado: Activo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Text(
                'Fecha de contratación: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (plazoController.text.trim().isEmpty) {
                  setState(() => camposInvalidos = true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      );
    },
  );

  if (confirmar == true) {
    // Segundo diálogo: mostrar resumen y confirmar
    final confirmarFinal = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar creación de contrato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se creará el siguiente contrato para el trabajador:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Datos del trabajador:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
            Text('RUT: ${trabajador.rut ?? ''}'),
            const SizedBox(height: 12),
            const Text('Datos del contrato:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Plazo: ${plazoController.text.trim()}'),
            Text('Estado: $estadoSeleccionado'),
            Text('Fecha de contratación: ${DateTime.now().toIso8601String().substring(0, 10)}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmarFinal == true) {
      // Mostrar indicador de carga efecto pasivo de que si se hace algo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creando contrato...'),
            ],
          ),
        ),
      );

      try {
        final contratoData = {
          'plazo_de_contrato': plazoController.text.trim(),
          'estado': estadoSeleccionado,
          'fecha_de_contratacion': DateTime.now().toIso8601String().substring(0, 10),
          'id_trabajadores': trabajador.id.toString(),
        };

        final trabajadorId = trabajador.id.toString();

        // Crear contrato en Supabase
        final idContrato = await createContratoSupabase(contratoData, trabajadorId);
        
        // Si se creó correctamente en Supabase, crear en MongoDB
        if (idContrato.isNotEmpty) {
          await createContratoMongo(contratoData, trabajadorId, idContrato);
        }

        // Actualizar la lista de trabajadores
        await fetchTrabajadores();

        // Cerrar diálogo de carga
        if (context.mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrato creado correctamente'),
            ),
          );
        }
      } catch (e) {
        // Cerrar diálogo de carga
        if (context.mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear contrato: $e'),
            ),
          );
        }
      }
    }
  }
}