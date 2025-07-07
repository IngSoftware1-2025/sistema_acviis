import 'package:flutter/material.dart';
import 'package:sistema_acviis/backend/controllers/contratos/actualizar_estado_contrato.dart';
import 'package:sistema_acviis/backend/controllers/comentarios/create_comentario.dart';

Future<void> mostrarDialogoEliminarContrato({
  required BuildContext context,
  required dynamic trabajador,
  required Future<void> Function() fetchTrabajadores,
}) async {
  // Verificar contratos disponibles para eliminar
  final contratos = (trabajador.contratos ?? [])
      .where((contrato) => contrato['estado'] != 'Reemplazado')
      .toList();

  // Verificar si hay contrato asociado
  final tieneContratoAsociado = (trabajador.contratos ?? [])
      .any((contrato) => contrato['estado'] == 'Activo' || contrato['estado'] == 'Finalizado');
  
  if (!tieneContratoAsociado) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay contrato asociado para eliminar.')),
    );
    return;
  }

  if (contratos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El trabajador no tiene contratos activos para eliminar.')),
    );
    return;
  }

  // Seleccionar el contrato a eliminar
  Map<String, dynamic>? contratoSeleccionado;
  if (contratos.length == 1) {
    contratoSeleccionado = contratos.first;
  } else {
    contratoSeleccionado = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar contrato a eliminar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona el contrato que deseas eliminar:'),
            const SizedBox(height: 12),
            ...contratos.map<Widget>((contrato) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: () => Navigator.pop(context, contrato),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contrato ID: ${contrato['id']}', 
                             style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Estado: ${contrato['estado']}'),
                        Text('Plazo: ${contrato['plazo_de_contrato']}'),
                        Text('Fecha: ${contrato['fecha_de_contratacion']}'),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  if (contratoSeleccionado == null) return;

  // Solicitar comentario obligatorio
  final comentarioController = TextEditingController();
  bool comentarioInvalido = false;
  
  final confirmarComentario = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Comentario para eliminar contrato'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del contrato a eliminar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trabajador: ${trabajador.nombreCompleto ?? ''}'),
                    Text('RUT: ${trabajador.rut ?? ''}'),
                    Text('Contrato ID: ${contratoSeleccionado!['id']}'),
                    Text('Estado: ${contratoSeleccionado['estado']}'),
                    Text('Plazo: ${contratoSeleccionado['plazo_de_contrato']}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Estás seguro que deseas eliminar este contrato?\n\nEsta acción no se puede deshacer.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentario obligatorio sobre la eliminación',
                  hintText: 'Explica el motivo de la eliminación del contrato...',
                  errorText: comentarioInvalido ? 'El comentario es obligatorio' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (comentarioInvalido) setState(() => comentarioInvalido = false);
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
              child: const Text('Siguiente'),
            ),
          ],
        ),
      );
    },
  );

  if (confirmarComentario == true) {
    // Pantalla de confirmación final
    final confirmarFinal = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación de contrato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Deseas eliminar el siguiente contrato?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Datos del trabajador:', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Nombre: ${trabajador.nombreCompleto ?? ''}'),
            Text('RUT: ${trabajador.rut ?? ''}'),
            const SizedBox(height: 12),
            const Text('Datos del contrato:', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('ID: ${contratoSeleccionado != null ? contratoSeleccionado['id'] : ''}'),
            Text('Estado: ${contratoSeleccionado != null ? contratoSeleccionado['estado'] : ''}'),
            Text('Plazo: ${contratoSeleccionado != null ? contratoSeleccionado['plazo_de_contrato'] : ''}'),
            Text('Fecha: ${contratoSeleccionado != null ? contratoSeleccionado['fecha_de_contratacion'] : ''}'),
            const SizedBox(height: 12),
            const Text('Motivo de eliminación:', style: TextStyle(fontWeight: FontWeight.w600)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                comentarioController.text.trim(),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'El contrato será marcado como "Reemplazado" y esta acción no se puede deshacer.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
            style: ElevatedButton.styleFrom(),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar Contrato'),
          ),
        ],
      ),
    );

    if (confirmarFinal == true) {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Eliminando contrato...'),
            ],
          ),
        ),
      );

      try {
        // Actualizar estado del contrato a "Reemplazado"
        await actualizarEstadoContrato(
          contratoSeleccionado['id'].toString(),
          'Reemplazado',
        );
        
        // Crear comentario asociado
        await crearComentario(
          idTrabajador: trabajador.id,
          idContrato: contratoSeleccionado['id'].toString(),
          comentario: comentarioController.text.trim(),
          fecha: DateTime.now(),
        );
        
        // Actualizar lista de trabajadores
        await fetchTrabajadores();
        
        // Cerrar diálogo de carga
        if (context.mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contrato eliminado correctamente'),
            ),
          );
        }
      } catch (e) {
        // Cerrar diálogo de carga
        if (context.mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar contrato: $e'),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se canceló la eliminación del contrato')),
      );
    }
  }
}