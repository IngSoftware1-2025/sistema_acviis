import 'package:flutter/material.dart';

Future<void> mostrarDialogoEliminarTrabajador({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function({
    required String idTrabajador,
    required String comentario,
    required DateTime fecha,
    String? idContrato,
  }) crearComentario,
  required Future<void> Function(String id, String estado) actualizarEstadoTrabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  final comentarioController = TextEditingController();
  bool comentarioInvalido = false;
  
  /*
  muestra un diálogo para confirmar la eliminación del trabajador
  y solicita un comentario obligatorio sobre la eliminación
  si el comentario es inválido, muestra un mensaje de error
  */
  final confirmacion = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Eliminar trabajador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta acción eliminará al trabajador del sistema.\n\n'
                'Por favor, ingresa un comentario obligatorio sobre la eliminación:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentario acerca de la eliminación',
                  errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (comentarioInvalido) {
                    setState(() => comentarioInvalido = false);
                  }
                },
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
                if (comentarioController.text.trim().isEmpty) {
                  setState(() => comentarioInvalido = true);
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    },
  );
  
  /*
  aquí se confirma la eliminación del trabajador
  y se muestra un diálogo de confirmación final
  con los detalles del trabajador
  a eliminar
  */
  if (confirmacion == true) {
    final confirmacionFinal = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Está seguro que desea eliminar al siguiente trabajador del sistema?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(trabajador.nombreCompleto ?? ''),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('RUT:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(trabajador.rut ?? ''),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Comentario: ${comentarioController.text.trim()}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción no se puede deshacer.',
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
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmacionFinal == true) {
      try {
        // Crea el comentario asociado al trabajador
        await crearComentario(
          idTrabajador: trabajador.id,
          comentario: comentarioController.text.trim(),
          fecha: DateTime.now(),
          idContrato: null,
        );
        // Actualiza el estado del trabajador a "Eliminado"
        await actualizarEstadoTrabajador(trabajador.id, 'Eliminado');
        await fetchTrabajadores();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trabajador eliminado correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}